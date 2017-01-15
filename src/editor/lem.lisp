(in-package :lem)

(export '(*after-init-hook*
          with-editor
          lem))

(defvar *after-init-hook* '())

(defvar *in-the-editor* nil)

(defvar *syntax-scan-window-recursive-p* nil)

(defun syntax-scan-window (window)
  (check-type window window)
  (when (and (enable-syntax-highlight-p (window-buffer window))
             (null *syntax-scan-window-recursive-p*))
    (let ((*syntax-scan-window-recursive-p* t))
      (window-see window)
      (syntax-scan-range (line-start (copy-point (window-view-point window) :temporary))
                         (or (line-offset (copy-point (window-view-point window) :temporary)
                                          (window-height window))
                             (buffers-end (window-buffer window)))))))

(defun syntax-scan-buffer (buffer)
  (check-type buffer buffer)
  (when (enable-syntax-highlight-p buffer)
    (syntax-scan-range (buffers-start buffer) (buffers-end buffer))))

(defun syntax-scan-current-view (&optional (window (current-window)))
  (cond
    ((get-bvar 'already-visited :buffer (window-buffer window))
     (syntax-scan-window window))
    (t
     (setf (get-bvar 'already-visited :buffer (window-buffer window)) t)
     (syntax-scan-buffer (window-buffer window)))))

(defun syntax-scan-point (start end old-len)
  (line-start start)
  (if (zerop old-len)
      (syntax-scan-range start end)
      (syntax-scan-range (line-start start) (line-end end))))

(defun setup ()
  (start-idle-timer "mainloop" 200 t
                    (lambda ()
                      (redraw-display)))
  (start-idle-timer "lazy-syntax-scan" 500 t
                    (lambda ()
                      (syntax-scan-current-view (current-window))
                      (redraw-display)))
  (add-hook *window-scroll-functions*
            (lambda (window)
              (syntax-scan-current-view window)))
  (add-hook *window-size-change-functions*
            (lambda (window)
              (syntax-scan-current-view window)))
  (add-hook *window-show-buffer-functions*
            (lambda (window)
              (syntax-scan-window window)))
  (add-hook *after-change-functions*
            'syntax-scan-point)
  (add-hook *find-file-hook*
            (lambda (buffer)
              (prepare-auto-mode buffer)
              (scan-file-property-list buffer)
              (syntax-scan-buffer buffer)))
  (add-hook *before-save-hook*
            (lambda (buffer)
              (scan-file-property-list buffer))))

(defun lem-internal ()
  (let* ((main-thread (bt:current-thread))
         (editor-thread (bt:make-thread
                         (lambda ()
                           (let ((*in-the-editor* t))
                             (let ((report (with-catch-bailout
                                             (command-loop t))))
                               (bt:interrupt-thread
                                main-thread
                                (lambda ()
                                  (error 'exit-editor :value report))))))
                         :name "editor")))
    (handler-case
        (loop
          (unless (bt:thread-alive-p editor-thread) (return))
          (let ((code (charms/ll:getch)))
            (cond ((= code -1))
                  ((= code 410)
                   (send-resize-screen-event charms/ll:*cols* charms/ll:*lines*))
                  ((= code (char-code C-\]))
                   (bt:interrupt-thread editor-thread
                                        (lambda ()
                                          (error 'editor-interrupt))))
                  (t
                   (send-event
                    (let ((nbytes (utf8-bytes code)))
                      (if (= nbytes 1)
                          (code-char code)
                          (let ((vec (make-array nbytes :element-type '(unsigned-byte 8))))
                            (setf (aref vec 0) code)
                            (loop :for i :from 1 :below nbytes
                                  :do (setf (aref vec i) (charms/ll:getch)))
                            (schar (babel:octets-to-string vec) 0)))))))))
      (exit-editor (c)
                   (return-from lem-internal (exit-editor-value c))))))

(let ((passed nil))
  (defun call-with-editor (function)
    (let ((report
           (with-catch-bailout
             (handler-bind ((error #'bailout)
                            #+sbcl (sb-sys:interactive-interrupt #'bailout))
               (unwind-protect (let ((*in-the-editor* t))
                                 (unless passed
                                   (setq passed t)
                                   (display-init)
                                   (window-init)
                                   (minibuf-init)
                                   (setup)
                                   (run-hooks *after-init-hook*))
                                 (funcall function))
                 (display-finalize))))))
      (when report
        (format t "~&~A~%" report)))))

(defmacro with-editor (() &body body)
  `(call-with-editor (lambda () ,@body)))

(defun lem (&rest args)
  (if *in-the-editor*
      (mapc 'find-file args)
      (with-editor ()
        (mapc 'find-file args)
        (lem-internal))))
