(in-package :cepl.stencil)

(define-const +valid-stencil-tests+
    '(:never :always :less :lequal :greater :gequal :equal :notequal
      #'never #'always #'< #'<= #'> #'>= #'= #'/=)
  :type list)

(defn stencil-test-to-enum ((test (or function keyword)))
    (signed-byte 32)
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (profile t))
  (cond
    ((or (eq test :never) (eq test #'never))
     #.(gl-enum :never))
    ((or (eq test :always) (eq test #'always))
     #.(gl-enum :always))
    ((or (eq test :less) (eq test #'<))
     #.(gl-enum :less))
    ((or (eq test :lequal) (eq test #'<=))
     #.(gl-enum :lequal))
    ((or (eq test :greater) (eq test #'>))
     #.(gl-enum :greater))
    ((or (eq test :gequal) (eq test #'>=))
     #.(gl-enum :gequal))
    ((or (eq test :equal) (eq test #'=))
     #.(gl-enum :equal))
    ((or (eq test :notequal) (eq test #'/=))
     #.(gl-enum :notequal))
    (t (error "CEPL: The stencil test must be one of the following:~{~%~a~}"
              +valid-stencil-tests+))))


(defn stencil-operation-to-enum ((operation (or function keyword)))
    (signed-byte 32)
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (profile t))
  (cond
    ((or (eq operation :keep) (eq operation #'keep))
     #.(gl-enum :keep))
    ((or (eq operation :invert) (eq operation #'stencil-invert))
     #.(gl-enum :invert))
    ((or (eq operation :zero) (eq operation #'zero))
     #.(gl-enum :zero))
    ((or (eq operation :replace) (eq operation #'stencil-replace))
     #.(gl-enum :replace))
    ((or (eq operation :incr) (eq operation #'stencil-incf))
     #.(gl-enum :incr))
    ((or (eq operation :incr-wrap) (eq operation #'stencil-incf-wrap))
     #.(gl-enum :incr-wrap))
    ((or (eq operation :decr) (eq operation #'stencil-decf))
     #.(gl-enum :decr))
    ((or (eq operation :decr-wrap) (eq operation #'stencil-decf-wrap))
     #.(gl-enum :decr-wrap))
    (t (error "CEPL: The stencil operation must be one of the following:~{~%~a~}"
              +valid-stencil-tests+))))


;;------------------------------------------------------------
;; Accessors

(defn-inline stencil-params-test ((params stencil-params)) function
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (stencil-test-enum-to-func (%stencil-params-test params)))

(defn-inline stencil-params-value ((params stencil-params)) (unsigned-byte 8)
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (%stencil-params-value params))

(defn-inline stencil-params-mask ((params stencil-params)) (unsigned-byte 8)
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (%stencil-params-mask params))

(defn-inline stencil-params-on-stencil-test-fail
    ((params stencil-params)) function
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (stencil-operation-enum-to-func
   (%stencil-params-on-stencil-test-fail params)))

(defn-inline stencil-params-on-stencil-pass-depth-test-fail
    ((params stencil-params)) function
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (stencil-operation-enum-to-func
   (%stencil-params-on-stencil-pass-depth-test-fail params)))

(defn-inline stencil-params-on-stencil-pass-depth-test-pass
    ((params stencil-params)) function
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (stencil-operation-enum-to-func
   (%stencil-params-on-stencil-pass-depth-test-pass params)))

(defn-inline stencil-params-on-sfail
    ((params stencil-params)) function
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (stencil-operation-enum-to-func
   (%stencil-params-on-stencil-test-fail params)))

(defn-inline stencil-params-on-dpfail
    ((params stencil-params)) function
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (stencil-operation-enum-to-func
   (%stencil-params-on-stencil-pass-depth-test-fail params)))

(defn-inline stencil-params-on-dppass
    ((params stencil-params)) function
  (declare (optimize (speed 3) (safety 1) (debug 1)))
  (stencil-operation-enum-to-func
   (%stencil-params-on-stencil-pass-depth-test-pass params)))

;;------------------------------------------------------------

(defn stencil-test-enum-to-func ((enum (signed-byte 32))) function
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (profile t))
  (ecase enum
    (#.(gl-enum :never) #'never)
    (#.(gl-enum :always) #'always)
    (#.(gl-enum :less) #'<)
    (#.(gl-enum :lequal) #'<=)
    (#.(gl-enum :greater) #'>)
    (#.(gl-enum :gequal) #'>=)
    (#.(gl-enum :equal) #'=)
    (#.(gl-enum :notequal) #'/=)))


(defn stencil-operation-enum-to-func ((enum (signed-byte 32))) function
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (profile t))
  (ecase enum
    (#.(gl-enum :keep) #'keep)
    (#.(gl-enum :invert) #'stencil-invert)
    (#.(gl-enum :zero) #'zero)
    (#.(gl-enum :replace) #'stencil-replace)
    (#.(gl-enum :incr) #'stencil-incf)
    (#.(gl-enum :incr-wrap) #'stencil-incf-wrap)
    (#.(gl-enum :decr) #'stencil-decf)
    (#.(gl-enum :decr-wrap) #'stencil-decf-wrap)))


(defn make-stencil-params
    (&key (test (or function keyword) #'never)
          (value (unsigned-byte 8) 0)
          (mask (unsigned-byte 8) 0)
          (on-stencil-test-fail (or function keyword) #'keep)
          (on-stencil-pass-depth-test-fail (or function keyword) #'keep)
          (on-stencil-pass-depth-test-pass (or function keyword) #'keep))
    stencil-params
  (assert (typep value '(unsigned-byte 8)))
  (assert (typep mask '(unsigned-byte 8)))
  (%make-stencil-params
   :test (stencil-test-to-enum test)

   :value value

   :mask mask

   :on-stencil-test-fail
   (stencil-operation-to-enum on-stencil-test-fail)

   :on-stencil-pass-depth-test-fail
   (stencil-operation-to-enum on-stencil-pass-depth-test-fail)

   :on-stencil-pass-depth-test-pass
   (stencil-operation-to-enum on-stencil-pass-depth-test-pass)))


(defmethod print-object ((sp stencil-params) stream)
  (print-unreadable-object (sp stream)
    (format stream "~@<STENCIL-PARAMS~:@_:TEST ~A~:@_:VALUE ~A~:@_:MASK ~A~:@_:ON-STENCIL-TEST-FAIL ~A~:@_:ON-STENCIL-PASS-DEPTH-TEST-FAIL ~A ~:@_:ON-STENCIL-PASS-DEPTH-TEST-PASS ~A~:>"
            (stencil-params-test sp)
            (stencil-params-value sp)
            (stencil-params-mask sp)
            (stencil-params-on-stencil-test-fail sp)
            (stencil-params-on-stencil-pass-depth-test-fail sp)
            (stencil-params-on-stencil-pass-depth-test-pass sp))))

;;------------------------------------------------------------
;; Get Current

(defn-inline %current-stencil-params ((face symbol)
                                      (cepl-context cepl-context))
    (values stencil-params (or null stencil-params))
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (profile t))
  (%with-cepl-context-slots (current-stencil-params-front
                             current-stencil-params-back)
      cepl-context
    (ecase face
      (:front (values current-stencil-params-front nil))
      (:back (values current-stencil-params-back nil))
      (:front-and-back (values current-stencil-params-front
                               current-stencil-params-back)))))

(defn current-stencil-params ((face symbol)
                              &optional (cepl-context cepl-context (cepl-context)))
    (values stencil-params (or null stencil-params))
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (inline %current-stencil-params)
           (profile t))
  (%current-stencil-params face cepl-context))

(define-compiler-macro current-stencil-params
    (face &optional cepl-context)
  (if cepl-context
    `(%current-stencil-params ,face ,cepl-context)
    `(%current-stencil-params ,face (cepl-context))))

;;------------------------------------------------------------
;; Set current

(defn (setf current-stencil-params) ((params stencil-params)
                                     (face symbol)
                                     &optional (cepl-context cepl-context (cepl-context)))
    stencil-params
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (profile t))
  (let ((enum (ecase face
                (:front #.(gl-enum :front))
                (:back #.(gl-enum :back))
                (:front-and-back #.(gl-enum :front-and-back)))))
    (%apply-stencil-params enum params cepl-context))
  params)

(define-compiler-macro (setf current-stencil-params)
    (&whole whole params face &optional cepl-context)
  (let ((enum (case face
                (:front #.(gl-enum :front))
                (:back #.(gl-enum :back))
                (:front-and-back #.(gl-enum :front-and-back))
                (otherwise face))))
    (cond
      ((symbolp enum) whole)

      (cepl-context `(%apply-stencil-params
                      ,enum ,params ,cepl-context))

      (t `(%apply-stencil-params
           ,enum ,params (cepl-context))))))

(defn %apply-stencil-params ((face (signed-byte 32))
                             (params stencil-params)
                             (cepl-context cepl-context))
    (values)
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (profile t))
  (%with-cepl-context-slots (current-stencil-params-front
                             current-stencil-params-back)
      cepl-context
    ;;
    ;; update context
    (let ((current
           (cond
             ((= face #.(gl-enum :front))
              (prog1 current-stencil-params-front
                (setf current-stencil-params-front params)))
             ((= face #.(gl-enum :back))
              (prog1 current-stencil-params-back
                (setf current-stencil-params-back params)))
             (t (setf current-stencil-params-front params)
                (setf current-stencil-params-back params)
                nil))))
      ;;
      ;; update gl
      (unless (eq params current)
        (unless (or (/= (%stencil-params-test params)
                        (%stencil-params-test current))
                    (/= (%stencil-params-value params)
                        (%stencil-params-value current))
                    (/= (%stencil-params-mask params)
                        (%stencil-params-mask current)))
          (gl:stencil-func-separate
           face
           (%stencil-params-test params)
           (%stencil-params-value params)
           (%stencil-params-mask params)))
        (unless (or (/= (%stencil-params-on-stencil-test-fail params)
                        (%stencil-params-on-stencil-test-fail current))
                    (/= (%stencil-params-on-stencil-pass-depth-test-fail
                         params)
                        (%stencil-params-on-stencil-pass-depth-test-fail
                         current))
                    (/= (%stencil-params-on-stencil-pass-depth-test-pass
                         params)
                        (%stencil-params-on-stencil-pass-depth-test-pass
                         current)))
          (gl:stencil-op-separate
           face
           (%stencil-params-on-stencil-test-fail params)
           (%stencil-params-on-stencil-pass-depth-test-fail params)
           (%stencil-params-on-stencil-pass-depth-test-pass params))))))
  (values))

;;------------------------------------------------------------
