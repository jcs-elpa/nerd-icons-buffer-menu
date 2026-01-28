;;; nerd-icons-buffer-menu.el --- Display nerd icons in `buffer-menu'  -*- lexical-binding: t; -*-

;; Copyright (C) 2023-2026  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/jcs-elpa/nerd-icons-buffer-menu
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (nerd-icons "0.0.1") (noflet "0.0.15") (msgu "0.1.0"))
;; Keywords: frames

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Display nerd icons in `buffer-menu'.
;;

;;; Code:

(require 'msgu)
(require 'nerd-icons)
(require 'noflet)

(defgroup nerd-icons-buffer-menu nil
  "Display nerd icons in `buffer-menu'."
  :prefix "nerd-icons-buffer-menu-"
  :group 'frames
  :link '(url-link :tag "Repository" "https://github.com/jcs-elpa/nerd-icons-buffer-menu"))

(defcustom nerd-icons-buffer-menu-icon-scale-factor 1.0
  "The base scale factor for the `height' face property of tab icons."
  :type 'number
  :group 'nerd-icons-buffer-menu)

(defcustom nerd-icons-buffer-menu-icon-v-adjust 0.01
  "The vertical adjust for tab icons."
  :type 'number
  :group 'nerd-icons-buffer-menu)

;;
;;; Entry

(defun nerd-icons-buffer-menu--enable ()
  "Enable `nerd-icons-buffer-menu-mode'."
  (advice-add 'list-buffers--refresh :around #'nerd-icons-buffer-menu--refresh)
  (msgu-silent (load-library "buff-menu.el")))  ; need to reload

(defun nerd-icons-buffer-menu--disable ()
  "Disable `nerd-icons-buffer-menu-mode'."
  (advice-remove 'list-buffers--refresh #'nerd-icons-buffer-menu--refresh))

;;;###autoload
(define-minor-mode nerd-icons-buffer-menu-mode
  "Minor mode `nerd-icons-buffer-menu-mode'."
  :global t
  :require 'nerd-icons-buffer-menu
  :group 'nerd-icons-buffer-menu
  (if nerd-icons-buffer-menu-mode (nerd-icons-buffer-menu--enable)
    (nerd-icons-buffer-menu--disable)))

;;
;;; Core

(defun nerd-icons-buffer-menu--refresh (func &rest args)
  "Execute around function `list-buffers--refresh'."
  (if (not nerd-icons-buffer-menu-mode)
      (apply func args)
    (let ((of-format-mode-line (symbol-function 'format-mode-line)))
      (noflet
        ((format-mode-line
          (format &optional face window buffer &rest _)
          (let ((o-value (funcall of-format-mode-line format face window buffer)))
            (cond
             ;; Mode name
             ((equal format mode-name)
              (let ((icon (let* ((icon (nerd-icons-icon-for-mode
                                        major-mode
                                        :height nerd-icons-buffer-menu-icon-scale-factor
                                        :v-adjust nerd-icons-buffer-menu-icon-v-adjust))
                                 (icon (if (or (null icon) (symbolp icon))
                                           nil
                                         icon)))
                            (if (and icon
                                     (char-displayable-p (string-to-char icon)))
                                (concat icon " ")
                              ""))))
                (concat icon o-value)))
             ;; Default
             (t o-value)))))
        (apply func args)))))

(provide 'nerd-icons-buffer-menu)
;;; nerd-icons-buffer-menu.el ends here
