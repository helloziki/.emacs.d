;; Time-stamp: <2015-02-24 10:05:18 kmodi>

;; http://emacs.stackexchange.com/a/401/115

;; Execute the `modi/org-include-img-from-pdf' function just before saving the file
(add-hook 'before-save-hook #'modi/org-include-img-from-pdf)
;; Execute the `modi/org-include-img-from-pdf' function before processing the
;; file for export
(add-hook 'org-export-before-processing-hook #'modi/org-include-img-from-pdf)

(defun modi/org-include-img-from-pdf (&rest ignore)
  "Convert the pdf files to image files.

Only looks at #HEADER: lines that have \":convertfrompdf t\".
This function does nothing if not in org-mode, so you can safely
add it to `before-save-hook'."
  (interactive)
  (when (derived-mode-p 'org-mode)
    (save-excursion
      (goto-char (point-min))
      (while (search-forward-regexp
              "^\\s-*#\\+HEADER:.*\\s-:convertfrompdf\\s-+t"
              nil 'noerror)
        (let* (filenoext imgext imgfile pdffile cmd)
          ;; Keep on going on to the next line till it finds a line with
          ;; `[[FILE]]'
          (while (progn
                   (forward-line 1)
                   (not (looking-at "\\[\\[\\(.*\\)\\.\\(.*\\)\\]\\]"))))
          (when (looking-at "\\[\\[\\(.*\\)\\.\\(.*\\)\\]\\]")
            (setq filenoext (match-string-no-properties 1))
            (setq imgext (match-string-no-properties 2))
            (setq imgfile (expand-file-name (concat filenoext "." imgext)))
            (setq pdffile (expand-file-name (concat filenoext "." "pdf")))
            (setq cmd (concat "convert -density 96 -quality 85 "
                              pdffile " " imgfile))
            (when (file-newer-than-file-p pdffile imgfile)
              ;; This block is executed only if pdffile is newer than imgfile
              ;; or if imgfile does not exist
              ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Testing-Accessibility.html
              (message "%s" cmd)
              (shell-command cmd))))))))


(provide 'org-include-img-from-pdf)
