;;; subdivide.el --- easy fast frame spliting
;;
;; Copyright (C) 2009 Fabián Ezequiel Gallina
;;
;; Author: Fabián Ezequiel Gallina (fabian@gnu.org.ar)
;; Created: 25 November 2009
;; Keywords: window, frame, convenience

;; This file is NOT part of GNU Emacs.

;; subdivide.el is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; subdivide.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;
;; --------------------------------------------------------------------

;;; Commentary:
;;
;; This package allows you to split the buffer by x horizontal splits
;; and y vertical splits at once.
;;
;; All you need to do is to call `subdivide-frame' which creates the
;; splits.
;;
;; For instance, this:
;;
;; (subdivide-frame 2 2)
;;
;; Will divide the frame like this:
;;
;;                    --------------
;;                    |      |     |
;;                    |      |     |
;;                    |------|------
;;                    |      |     |
;;                    |      |     |
;;                    --------------
;;
;; Also note that if you call `subdivide-frame' interactively it will
;; prompt you for the split values.

;; Requirements:
;;
;; You will need windmove.el which comes with GNU/Emacs 23 by default.

;; Installation:
;;
;; Put the following line in your `.emacs' file:
;;
;; (require 'subdivide)

;;; Acknowledgements:
;;

;;; Code:
(require 'windmove)


;; Inspired in this article:
;; http://curiousprogrammer.wordpress.com/2009/06/08/error-handling-in-emacs-lisp/
(defmacro subdivide-windmove (direction &optional times)
  "Macro to execute windmove commands safely. Will return nil
when is not possible to move to DIRECTION.

The optional TIMES parameter states how many times the windmove
command will be repeated"
  `(unwind-protect
       (let ((retval)
             (repeat ,times))
         (condition-case ex
             (setq retval
                   (progn
                     (when (equal repeat nil)
                       (setq repeat 1))
                     (dotimes (i repeat)
                       (funcall
                        (intern-soft
                         (concat
                          "windmove-" (prin1-to-string ,direction)))))))
           ('error
            (setq retval nil)))
         (windowp retval))
     nil))


;; This will do all the magic we need. After each split
;; balance-windows should be applied so we can use all the available
;; space in the buffer
(defun subdivide-frame (width height)
  "divides the frame in WIDTH horizontal splits and HEIGHT
vertical splits"
  (interactive
   (list
    (read-number "number of horizontal splits: ")
    (read-number "number of vertical splits: ")))
  (let ((wdiv (ceiling (/ (float width) 2)))
        (hdiv (ceiling (/ (float height) 2)))
        (wadjust 0)
        (hadjust 0)
        (wwadjust 1))
    (when (and (evenp width)
               (not (equal width 2)))
      (setq wadjust 1))
    (when (and (evenp height)
               (not (equal height 2)))
      (setq hadjust 1))
    (when (equal width 1)
      (setq wwadjust 0))
    (delete-other-windows)
    (when (not (equal width 1))
      (dotimes (i (+ wadjust wdiv))
        (split-window-horizontally)
        (balance-windows)))
    (when (not (equal height 1))
      (dotimes (i (+ wwadjust wadjust wdiv))
        (dotimes (j (+ hadjust hdiv))
          (split-window-vertically)
          (balance-windows))
        (subdivide-windmove 'right)))
    (subdivide-windmove 'left width)
    (subdivide-windmove 'up height)))


(provide 'subdivide)
;;; subdivide.el ends here