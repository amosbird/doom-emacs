;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; lang/cc/doctor.el

(when (require 'rtags nil t)
  ;; rtags
  (let ((bins (cl-remove-if #'executable-find `(,rtags-rdm-binary-name ,rtags-rc-binary-name))))
    (when (/= (length bins) 0)
      (warn! "Couldn't find the rtag client and/or server programs %s. Disabling rtags support" bins))))

;; irony server
(when (require 'irony nil t)
  (unless (file-directory-p irony-server-install-prefix)
    (warn! "Irony server isn't installed. Run M-x irony-install-server")))

(when (featurep! :completion company)
  ;; glslangValidator
  (unless (executable-find "glslangValidator")
    (warn! "Couldn't find glslangValidator. GLSL code completion is disabled")))
