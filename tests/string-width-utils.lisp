(defpackage :lem-tests/string-width-utils
  (:use :cl :rove)
  (:import-from :lem
                :control-char
                :wide-char-p
                :char-width
                :string-width
                :wide-index))
(in-package :lem-tests/string-width-utils)

(defparameter +eastasian-full-pairs+
  (list '(#x1100 #x115f) '(#x231a #x231b) '(#x2329 #x232a) '(#x23e9 #x23ec)
        '(#x23f0 #x23f0) '(#x23f3 #x23f3) '(#x25fd #x25fe) '(#x2614 #x2615)
        '(#x2648 #x2653) '(#x267f #x267f) '(#x2693 #x2693) '(#x26a1 #x26a1)
        '(#x26aa #x26ab) '(#x26bd #x26be) '(#x26c4 #x26c5) '(#x26ce #x26ce)
        '(#x26d4 #x26d4) '(#x26ea #x26ea) '(#x26f2 #x26f3) '(#x26f5 #x26f5)
        '(#x26fa #x26fa) '(#x26fd #x26fd) '(#x2705 #x2705) '(#x270a #x270b)
        '(#x2728 #x2728) '(#x274c #x274c) '(#x274e #x274e) '(#x2753 #x2755)
        '(#x2757 #x2757) '(#x2795 #x2797) '(#x27b0 #x27b0) '(#x27bf #x27bf)
        '(#x2b1b #x2b1c) '(#x2b50 #x2b50) '(#x2b55 #x2b55) '(#x2e80 #x2e99)
        '(#x2e9b #x2ef3) '(#x2f00 #x2fd5) '(#x2ff0 #x2ffb) '(#x3000 #x303e)
        '(#x3041 #x3096) '(#x3099 #x30ff) '(#x3105 #x312f) '(#x3131 #x318e)
        '(#x3190 #x31ba) '(#x31c0 #x31e3) '(#x31f0 #x321e) '(#x3220 #x3247)
        '(#x3250 #x32fe) '(#x3300 #x4dbf) '(#x4e00 #xa48c) '(#xa490 #xa4c6)
        '(#xa960 #xa97c) '(#xac00 #xd7a3) '(#xf900 #xfaff) '(#xfe10 #xfe19)
        '(#xfe30 #xfe52) '(#xfe54 #xfe66) '(#xfe68 #xfe6b) '(#xff01 #xff60)
        '(#xffe0 #xffe6) '(#x16fe0 #x16fe1) '(#x17000 #x187f1) '(#x18800 #x18af2)
        '(#x1b000 #x1b11e) '(#x1b170 #x1b2fb) '(#x1f004 #x1f004) '(#x1f0cf #x1f0cf)
        '(#x1f18e #x1f18e) '(#x1f191 #x1f19a) '(#x1f200 #x1f202) '(#x1f210 #x1f23b)
        '(#x1f240 #x1f248) '(#x1f250 #x1f251) '(#x1f260 #x1f265) '(#x1f300 #x1f320)
        '(#x1f32d #x1f335) '(#x1f337 #x1f37c) '(#x1f37e #x1f393) '(#x1f3a0 #x1f3ca)
        '(#x1f3cf #x1f3d3) '(#x1f3e0 #x1f3f0) '(#x1f3f4 #x1f3f4) '(#x1f3f8 #x1f43e)
        '(#x1f440 #x1f440) '(#x1f442 #x1f4fc) '(#x1f4ff #x1f53d) '(#x1f54b #x1f54e)
        '(#x1f550 #x1f567) '(#x1f57a #x1f57a) '(#x1f595 #x1f596) '(#x1f5a4 #x1f5a4)
        '(#x1f5fb #x1f64f) '(#x1f680 #x1f6c5) '(#x1f6cc #x1f6cc) '(#x1f6d0 #x1f6d2)
        '(#x1f6eb #x1f6ec) '(#x1f6f4 #x1f6f9) '(#x1f910 #x1f93e) '(#x1f940 #x1f970)
        '(#x1f973 #x1f976) '(#x1f97a #x1f97a) '(#x1f97c #x1f9a2) '(#x1f9b0 #x1f9b9)
        '(#x1f9c0 #x1f9c2) '(#x1f9d0 #x1f9ff) '(#x20000 #x2fffd) '(#x30000 #x3fffd)))

(defparameter +control-char-pairs+
  '((#\Nul "^@")
    (#\Soh "^A")
    (#\Stx "^B")
    (#\Etx "^C")
    (#\Eot "^D")
    (#\Enq "^E")
    (#\Ack "^F")
    (#\Bel "^G")
    (#\Backspace "^H")
    (#\Tab "^I")
    (#\Vt "^K")
    (#\Page "^L")
    (#\Return "^R")
    (#\So "^N")
    (#\Si "^O")
    (#\Dle "^P")
    (#\Dc1 "^Q")
    (#\Dc2 "^R")
    (#\Dc3 "^S")
    (#\Dc4 "^T")
    (#\Nak "^U")
    (#\Syn "^V")
    (#\Etb "^W")
    (#\Can "^X")
    (#\Em "^Y")
    (#\Sub "^Z")
    (#\Esc "^[")
    (#\Fs "^\\")
    (#\Gs "^]")
    (#\Rs "^^")
    (#\Us "^_")
    (#\Rubout "^?")
    (#\UE000 "\\0")
    (#\UE001 "\\1")
    (#\UE002 "\\2")
    (#\UE003 "\\3")
    (#\UE004 "\\4")
    (#\UE005 "\\5")
    (#\UE006 "\\6")
    (#\UE007 "\\7")
    (#\UE008 "\\8")
    (#\UE009 "\\9")
    (#\UE00A "\\10")
    (#\UE00B "\\11")
    (#\UE00C "\\12")
    (#\UE00D "\\13")
    (#\UE00E "\\14")
    (#\UE00F "\\15")
    (#\UE010 "\\16")
    (#\UE011 "\\17")
    (#\UE012 "\\18")
    (#\UE013 "\\19")
    (#\UE014 "\\20")
    (#\UE015 "\\21")
    (#\UE016 "\\22")
    (#\UE017 "\\23")
    (#\UE018 "\\24")
    (#\UE019 "\\25")
    (#\UE01A "\\26")
    (#\UE01B "\\27")
    (#\UE01C "\\28")
    (#\UE01D "\\29")
    (#\UE01E "\\30")
    (#\UE01F "\\31")
    (#\UE020 "\\32")
    (#\UE021 "\\33")
    (#\UE022 "\\34")
    (#\UE023 "\\35")
    (#\UE024 "\\36")
    (#\UE025 "\\37")
    (#\UE026 "\\38")
    (#\UE027 "\\39")
    (#\UE028 "\\40")
    (#\UE029 "\\41")
    (#\UE02A "\\42")
    (#\UE02B "\\43")
    (#\UE02C "\\44")
    (#\UE02D "\\45")
    (#\UE02E "\\46")
    (#\UE02F "\\47")
    (#\UE030 "\\48")
    (#\UE031 "\\49")
    (#\UE032 "\\50")
    (#\UE033 "\\51")
    (#\UE034 "\\52")
    (#\UE035 "\\53")
    (#\UE036 "\\54")
    (#\UE037 "\\55")
    (#\UE038 "\\56")
    (#\UE039 "\\57")
    (#\UE03A "\\58")
    (#\UE03B "\\59")
    (#\UE03C "\\60")
    (#\UE03D "\\61")
    (#\UE03E "\\62")
    (#\UE03F "\\63")
    (#\UE040 "\\64")
    (#\UE041 "\\65")
    (#\UE042 "\\66")
    (#\UE043 "\\67")
    (#\UE044 "\\68")
    (#\UE045 "\\69")
    (#\UE046 "\\70")
    (#\UE047 "\\71")
    (#\UE048 "\\72")
    (#\UE049 "\\73")
    (#\UE04A "\\74")
    (#\UE04B "\\75")
    (#\UE04C "\\76")
    (#\UE04D "\\77")
    (#\UE04E "\\78")
    (#\UE04F "\\79")
    (#\UE050 "\\80")
    (#\UE051 "\\81")
    (#\UE052 "\\82")
    (#\UE053 "\\83")
    (#\UE054 "\\84")
    (#\UE055 "\\85")
    (#\UE056 "\\86")
    (#\UE057 "\\87")
    (#\UE058 "\\88")
    (#\UE059 "\\89")
    (#\UE05A "\\90")
    (#\UE05B "\\91")
    (#\UE05C "\\92")
    (#\UE05D "\\93")
    (#\UE05E "\\94")
    (#\UE05F "\\95")
    (#\UE060 "\\96")
    (#\UE061 "\\97")
    (#\UE062 "\\98")
    (#\UE063 "\\99")
    (#\UE064 "\\100")
    (#\UE065 "\\101")
    (#\UE066 "\\102")
    (#\UE067 "\\103")
    (#\UE068 "\\104")
    (#\UE069 "\\105")
    (#\UE06A "\\106")
    (#\UE06B "\\107")
    (#\UE06C "\\108")
    (#\UE06D "\\109")
    (#\UE06E "\\110")
    (#\UE06F "\\111")
    (#\UE070 "\\112")
    (#\UE071 "\\113")
    (#\UE072 "\\114")
    (#\UE073 "\\115")
    (#\UE074 "\\116")
    (#\UE075 "\\117")
    (#\UE076 "\\118")
    (#\UE077 "\\119")
    (#\UE078 "\\120")
    (#\UE079 "\\121")
    (#\UE07A "\\122")
    (#\UE07B "\\123")
    (#\UE07C "\\124")
    (#\UE07D "\\125")
    (#\UE07E "\\126")
    (#\UE07F "\\127")
    (#\UE080 "\\128")
    (#\UE081 "\\129")
    (#\UE082 "\\130")
    (#\UE083 "\\131")
    (#\UE084 "\\132")
    (#\UE085 "\\133")
    (#\UE086 "\\134")
    (#\UE087 "\\135")
    (#\UE088 "\\136")
    (#\UE089 "\\137")
    (#\UE08A "\\138")
    (#\UE08B "\\139")
    (#\UE08C "\\140")
    (#\UE08D "\\141")
    (#\UE08E "\\142")
    (#\UE08F "\\143")
    (#\UE090 "\\144")
    (#\UE091 "\\145")
    (#\UE092 "\\146")
    (#\UE093 "\\147")
    (#\UE094 "\\148")
    (#\UE095 "\\149")
    (#\UE096 "\\150")
    (#\UE097 "\\151")
    (#\UE098 "\\152")
    (#\UE099 "\\153")
    (#\UE09A "\\154")
    (#\UE09B "\\155")
    (#\UE09C "\\156")
    (#\UE09D "\\157")
    (#\UE09E "\\158")
    (#\UE09F "\\159")
    (#\UE0A0 "\\160")
    (#\UE0A1 "\\161")
    (#\UE0A2 "\\162")
    (#\UE0A3 "\\163")
    (#\UE0A4 "\\164")
    (#\UE0A5 "\\165")
    (#\UE0A6 "\\166")
    (#\UE0A7 "\\167")
    (#\UE0A8 "\\168")
    (#\UE0A9 "\\169")
    (#\UE0AA "\\170")
    (#\UE0AB "\\171")
    (#\UE0AC "\\172")
    (#\UE0AD "\\173")
    (#\UE0AE "\\174")
    (#\UE0AF "\\175")
    (#\UE0B0 "\\176")
    (#\UE0B1 "\\177")
    (#\UE0B2 "\\178")
    (#\UE0B3 "\\179")
    (#\UE0B4 "\\180")
    (#\UE0B5 "\\181")
    (#\UE0B6 "\\182")
    (#\UE0B7 "\\183")
    (#\UE0B8 "\\184")
    (#\UE0B9 "\\185")
    (#\UE0BA "\\186")
    (#\UE0BB "\\187")
    (#\UE0BC "\\188")
    (#\UE0BD "\\189")
    (#\UE0BE "\\190")
    (#\UE0BF "\\191")
    (#\UE0C0 "\\192")
    (#\UE0C1 "\\193")
    (#\UE0C2 "\\194")
    (#\UE0C3 "\\195")
    (#\UE0C4 "\\196")
    (#\UE0C5 "\\197")
    (#\UE0C6 "\\198")
    (#\UE0C7 "\\199")
    (#\UE0C8 "\\200")
    (#\UE0C9 "\\201")
    (#\UE0CA "\\202")
    (#\UE0CB "\\203")
    (#\UE0CC "\\204")
    (#\UE0CD "\\205")
    (#\UE0CE "\\206")
    (#\UE0CF "\\207")
    (#\UE0D0 "\\208")
    (#\UE0D1 "\\209")
    (#\UE0D2 "\\210")
    (#\UE0D3 "\\211")
    (#\UE0D4 "\\212")
    (#\UE0D5 "\\213")
    (#\UE0D6 "\\214")
    (#\UE0D7 "\\215")
    (#\UE0D8 "\\216")
    (#\UE0D9 "\\217")
    (#\UE0DA "\\218")
    (#\UE0DB "\\219")
    (#\UE0DC "\\220")
    (#\UE0DD "\\221")
    (#\UE0DE "\\222")
    (#\UE0DF "\\223")
    (#\UE0E0 "\\224")
    (#\UE0E1 "\\225")
    (#\UE0E2 "\\226")
    (#\UE0E3 "\\227")
    (#\UE0E4 "\\228")
    (#\UE0E5 "\\229")
    (#\UE0E6 "\\230")
    (#\UE0E7 "\\231")
    (#\UE0E8 "\\232")
    (#\UE0E9 "\\233")
    (#\UE0EA "\\234")
    (#\UE0EB "\\235")
    (#\UE0EC "\\236")
    (#\UE0ED "\\237")
    (#\UE0EE "\\238")
    (#\UE0EF "\\239")
    (#\UE0F0 "\\240")
    (#\UE0F1 "\\241")
    (#\UE0F2 "\\242")
    (#\UE0F3 "\\243")
    (#\UE0F4 "\\244")
    (#\UE0F5 "\\245")
    (#\UE0F6 "\\246")
    (#\UE0F7 "\\247")
    (#\UE0F8 "\\248")
    (#\UE0F9 "\\249")
    (#\UE0FA "\\250")
    (#\UE0FB "\\251")
    (#\UE0FC "\\252")
    (#\UE0FD "\\253")
    (#\UE0FE "\\254")
    (#\UE0FF "\\255")))

(deftest control-char
  (loop :for code :from 0 :below 128
        :for char := (code-char code)
        :when (alphanumericp char)
        :do (ok (not (control-char char))))
  (loop :for (char control-char) :in +control-char-pairs+
        :do (ok (equal (control-char char) control-char))))

#-abcl
(deftest wide-char-p
  (let ((alphabet-or-numbers
          (loop :for code :from 0 :below 128
                :for char := (code-char code)
                :when (alphanumericp char)
                :collect char)))
    (ok (loop :for char :in alphabet-or-numbers
              :always (not (wide-char-p char)))))
  (let ((control-chars
          (loop :for code :from 0 :to 127
                :for char := (code-char code)
                :unless (or (graphic-char-p char)
                            (member char '(#\newline)))
                :collect char)))
    (ok (loop :for char :in control-chars
              :always (wide-char-p char))))
  (ok (loop :for (start end) :in +eastasian-full-pairs+
            :always (loop :for code :from start :to end
                          :always (wide-char-p (code-char code)))))
  (ok (not (wide-char-p (code-char #x1f336))))
  (ok (not (wide-char-p (code-char #x1f4fd)))))

(deftest char-width
  (testing "alphabet"
    (ok (eql 1 (char-width #\a 0)))
    (ok (eql 2 (char-width #\a 1))))
  (testing "tab"
    (ok (loop :for i :from 0 :below 8
              :always (eql 8 (char-width #\tab i))))
    (ok (loop :for i :from 8 :below 16
              :always (eql 16 (char-width #\tab i))))
    (ok (eql 10 (char-width #\tab 9 :tab-size 10))))
  (testing "control"
    (ok (eql 2 (char-width #\Nul 0)))
    (ok (eql 3 (char-width #\Nul 1)))
    (ok (eql 4 (char-width #\UE0FF 0)))
    (ok (eql 5 (char-width #\UE0FF 1)))
    (ok (eql 6 (char-width #\UE0FF 2))))
  (testing "wide"
    (ok (eql 2 (char-width #\あ 0)))
    (ok (eql 3 (char-width #\あ 1)))
    (dotimes (code 127)
      (let ((char (code-char code)))
        (unless (or (graphic-char-p char)
                    (char= char #\newline)
                    (char= char #\tab))
          (ok (eql 2 (char-width (code-char code) 0)))))))
  (testing "newline"
    (ok (eql 0 (char-width #\newline 0)))))

(deftest string-width
  (ok (eql 1 (string-width "a")))
  (ok (eql 2 (string-width "ab")))
  (ok (eql 3 (string-width "abc")))
  (ok (eql 2 (string-width "abc" :start 1)))
  (ok (eql 2 (string-width "abc" :end 2)))
  (ok (eql 2 (string-width "abcdef" :start 1 :end 3)))
  (ok (eql 2 (string-width "あ")))
  (ok (eql 3 (string-width "aあ")))
  (ok (eql 0 (string-width "abcdeあいうえお" :end 0)))
  (ok (eql 3 (string-width "abcdeあいうえお" :end 3)))
  (ok (eql 1 (string-width "abcdeあいうえお" :start 4 :end 5)))
  (ok (eql 3 (string-width "abcdeあいうえお" :start 4 :end 6)))
  (ok (eql 5 (string-width "abcdeあいうえお" :start 4 :end 7)))
  (ok (eql 10 (string-width (format nil "~Aab" #\tab))))
  (ok (eql 10 (string-width (format nil "ab~Aab" #\tab))))
  (ok (eql 5 (string-width (format nil "~Aab" #\tab) :tab-size 3)))
  (ok (eql 2 (string-width (format nil "~Aab" #\tab) :start 1)))
  (ok (eql 5 (string-width (format nil "ab~Aab" #\tab) :tab-size 3)))
  (ok (eql 5 (string-width (format nil "ab~Aab" #\tab) :tab-size 1)))
  (ok (eql 3 (string-width (format nil "あ~A" #\tab) :tab-size 1)))
  (ok (eql 3 (string-width (format nil "~Aaあ" #\tab) :start 1)))
  (ok (eql 6 (string-width (format nil "~Aaあ" #\tab) :tab-size 5 :start 0 :end 2))))

(deftest wide-index
  (ok (eql 1 (wide-index "abc" 1)))
  (ok (eql 2 (wide-index "abc" 2)))
  (ok (eql nil (wide-index "abc" 3)))
  (ok (eql nil (wide-index "abc" 10)))
  (ok (eql 0 (wide-index "あいえうお" 0)))
  (ok (eql 0 (wide-index "あいえうお" 1)))
  (ok (eql 1 (wide-index "あいえうお" 2)))
  (ok (eql 1 (wide-index "あいえうお" 3)))
  (ok (eql 2 (wide-index "あいえうお" 4)))
  (ok (eql 2 (wide-index "あいえ" 5)))
  (ok (eql nil (wide-index "あいえ" 6)))
  (ok (eql 0 (wide-index (format nil "~Aabcdefghijk" #\tab) 5)))
  (ok (eql 2 (wide-index (format nil "~Aabcdefghijk" #\tab) 5 :tab-size 4)))
  (ok (eql 6 (wide-index (format nil "~Aabcdefghijk" #\tab) 5 :start 1)))
  (ok (eql 5 (wide-index (format nil "~Aa~Abcdefghijk" #\tab #\tab) 5 :start 1 :tab-size 3))))
