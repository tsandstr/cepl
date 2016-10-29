(in-package :cepl.pipelines)

;; (bake 'foo :jam #'(ham :int))

(defmacro bake (pipeline &rest uniforms &key &allow-other-keys)
  (labels ((expand-literal-func (x)
             (if (and (listp x) (eq (first x) 'function))
                 `(gpu-function ,(second x))
                 x)))
    `(%bake ,pipeline ,@(mapcar #'expand-literal-func uniforms))))


(defun %bake (pipeline &rest uniforms &key &allow-other-keys)
  (let* ((pipeline (etypecase pipeline
                     ((or list symbol) (pipeline-spec pipeline)))))
    (bake-and-g-> (remove-if-not #'cdr (pipeline-stage-pairs pipeline))
                  uniforms)))


(defun bake-and-g-> (stage-pairs replacements)
  (let* ((stage-pairs (pairs-key-to-stage stage-pairs))
	 (glsl-version (compute-glsl-version-from-stage-pairs stage-pairs))
	 (stage-pairs (swap-versions stage-pairs glsl-version)))
    ;;(assert that all replacements are in one of the stages uniforms)
    (make-n-compile-lambda-pipeline
     (mapcan (lambda (pair)
               (list (first pair)
                     (dbind (in-args uniforms nil body)
                         (parsed-gpipe-args->v-translate-args
                          pair (group replacements 2))
                       (let ((args (append in-args
                                           (when uniforms
                                             (cons '&uniforms uniforms)))))
                         (make-gpu-lambda args (list body))))))
             stage-pairs)
     nil)))