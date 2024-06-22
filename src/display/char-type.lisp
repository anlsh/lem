(in-package :lem-core)

(deftype char-type ()
  '(member :latin :cjk :braille :emoji :icon :control))

(defun cjk-char-code-p (code)
  (or (<= #x4E00 code #x9FFF)
      (<= #x3040 code #x309F)
      (<= #x30A0 code #x30FF)
      (<= #xAC00 code #xD7A3)))

(defun latin-char-code-p (code)
  (or (<= #x0000 code #x007F)
      (<= #x0080 code #x00FF)
      (<= #x0100 code #x017F)
      (<= #x0180 code #x024F)))

(defun emoji-char-code-p (code)
  (or (<= #x1F300 code #x1F6FF)
      (<= #x1F900 code #x1F9FF)
      (<= #x1F600 code #x1F64F)
      (<= #x1F700 code #x1F77F)))

(defun braille-char-code-p (code)
  (<= #x2800 code #x28ff))

(defun icon-char-code-p (code)
  (icon-value code :font))

(defun char-type (char)
  (let ((code (char-code char)))
    (cond ((control-char char)
           :control)
          ((eql code #x1f4c1)
           :folder)
          ((<= code 128)
           :latin)
          ((icon-char-code-p code)
           :icon)
          ((braille-char-code-p code)
           :braille)
          ((cjk-char-code-p code)
           :cjk)
          ((latin-char-code-p code)
           :latin)
          ((emoji-char-code-p code)
           :emoji)
          ((icon-code-p code)
           :latin)
          (t
           :cjk))))
