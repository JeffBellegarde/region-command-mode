;;; region-command-mode.el --- Emacs to activate keybindings when region is active. -*- lexical-binding: t -*-
;; Copyright (C) 2016  Jeff Bellegarde

;; Author: Jeff Bellegarde <bellegar@gmail.com>
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:
(require 'bind-key)

(make-variable-buffer-local
 (defvar region-command-mode-start-position nil
   "The original position of point when region-command-mode was started."))

(make-variable-buffer-local
 (defvar region-command-mode-depth 0))

(defvar region-command-mode-keymap (make-sparse-keymap))

(defun region-command-mode-quit ()
  (interactive)
  (if region-command-mode-start-position
      (goto-char region-command-mode-start-position))
  (deactivate-mark))
;; (setq deactivate-mark-hook '())
(bind-keys :map region-command-mode-keymap
           ("q" . region-command-mode-quit)
           ("<SPC>" . region-command-mode-deactivate)
           ("r" . rectangle-mark-mode)
           ("x" . exchange-point-and-mark))

(defun region-command-mode--ensure-mode-keymap-is-accessible (test-key minor-mode-name)
  (unless (eq (car (car (minor-mode-key-binding ".")))
              minor-mode-name)
    (let ((mode-entry (assoc minor-mode-name minor-mode-map-alist)))
      (setq minor-mode-map-alist (assq-delete-all minor-mode-name minor-mode-map-alist))
      (push mode-entry minor-mode-map-alist))))

(define-minor-mode region-command-active-mode
  "Allows commands when the region is active.

This the internal mode that is activated when the region is active. It should
not be used directly. When active, an additional keymap
(`region-command-mode-keymap') is active. Users can add keys to the keymap
`region-command-mode-keymap' to add their own commands. The standard minor mode
hook `region-command-active-mode-hook' can be used."
  :lighter " RCA"
  :keymap region-command-mode-keymap
  (if region-command-active-mode
      (progn
        (region-command-mode--ensure-mode-keymap-is-accessible "." 'region-command-active-mode)
        (add-hook 'post-command-hook 'region-command-mode--check-if-done)
        (setq region-command-mode-start-position (point)))
    (remove-hook 'post-command-hook 'region-command-mode--check-if-done)
    (setq region-command-mode-start-position nil)))

(defun region-command-mode--check-if-done ()
  ;; (message "checking if done %s %s" mark-active deactivate-mark)
  (when (or (not mark-active) deactivate-mark)
    (region-command-mode-deactivate)))

(defun region-command-mode-activate ()
  (unless region-command-active-mode
    ;; (message "region-command-mode-activating")
    (region-command-active-mode 1)))

(defun region-command-mode-deactivate ()
  (interactive)
  ;; (message "region-command-mode-deactivating")
  (region-command-active-mode 0))

;;;###autoload
(define-minor-mode region-command-mode
  "Enable region command mode.
"
  :lighter " RC"
  :global t
  (if region-command-mode
      (progn
        (add-hook 'activate-mark-hook 'region-command-mode-activate)
        ;; (add-hook 'deactivate-mark-hook 'region-command-mode-deactivate)
        )
    (remove-hook 'activate-mark-hook 'region-command-mode-activate)
    ;; (remove-hook 'deactivate-mark-hook 'region-command-mode-deactivate)
    (region-command-mode-deactivate)))


(provide 'region-command-mode)

;;; region-command-mode.el ends here
