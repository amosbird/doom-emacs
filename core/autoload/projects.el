;;; core/autoload/projects.el -*- lexical-binding: t; -*-

;;;###autoload
(autoload 'projectile-relevant-known-projects "projectile")


;;
;; Macros

;;;###autoload
(defmacro without-project-cache! (&rest body)
  "Run BODY with projectile's project-root cache disabled. This is necessary if
you want to interactive with a project other than the one you're in."
  `(let ((projectile-project-root-cache (make-hash-table :test 'equal))
         projectile-project-name
         projectile-require-project-root)
     ,@body))

;;;###autoload
(defmacro project-file-exists-p! (files)
  "Checks if the project has the specified FILES.
Paths are relative to the project root, unless they start with ./ or ../ (in
which case they're relative to `default-directory'). If they start with a slash,
they are absolute."
  `(file-exists-p! ,files (doom-project-root)))


;;
;; Commands

;;;###autoload
(defun doom/find-file-in-other-project (project-root)
  "Preforms `projectile-find-file' in a known project of your choosing."
  (interactive
   (list
    (completing-read "Find file in project: " (projectile-relevant-known-projects)
                     nil nil nil nil (doom-project-root))))
  (unless (file-directory-p project-root)
    (error "Project directory '%s' doesn't exist" project-root))
  (doom-project-find-file project-root))

;;;###autoload
(defun doom/browse-in-other-project (project-root)
  "Preforms `find-file' in a known project of your choosing."
  (interactive
   (list
    (completing-read "Browse in project: " (projectile-relevant-known-projects)
                     nil nil nil nil (doom-project-root))))
  (unless (file-directory-p project-root)
    (error "Project directory '%s' doesn't exist" project-root))
  (doom-project-browse project-root))


;;
;; Library

;;;###autoload
(defalias 'doom-project-p #'projectile-project-p)

;;;###autoload
(defalias 'doom-project-root #'projectile-project-root)

;;;###autoload
(defun doom-project-name (&optional dir)
  "Return the name of the current project."
  (let ((project-root (or (projectile-project-root dir)
                          (if dir (expand-file-name dir)))))
    (if project-root
        (funcall projectile-project-name-function project-root)
      "-")))

;;;###autoload
(defun doom-project-expand (name &optional dir)
  "Expand NAME to project root."
  (expand-file-name name (projectile-project-root dir)))

;;;###autoload
(defun doom-project-find-file (dir)
  "Fuzzy-find a file under DIR.

Will resolve to the nearest project root above DIR. If no project can be found,
the search will be rooted from DIR."
  (unless (file-directory-p dir)
    (error "Directory %S does not exist" dir))
  (let* ((default-directory (file-truename (expand-file-name dir)))
         (projectile-project-root
          (or (projectile-project-root)
              default-directory)))
    (call-interactively
     ;; Intentionally avoid `helm-projectile-find-file', because it runs
     ;; asynchronously, and thus doesn't see the lexical `default-directory'
     (if (featurep! :completion ivy)
         #'counsel-projectile-find-file
       #'projectile-find-file))))

;;;###autoload
(defun doom-project-browse (dir)
  "Traverse a file structure starting linearly from DIR."
  (let ((default-directory (file-truename (expand-file-name dir))))
    (call-interactively
     (cond ((featurep! :completion ivy)
            #'counsel-find-file)
           ((featurep! :completion helm)
            #'helm-find-files)
           (#'find-file)))))
