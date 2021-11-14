(in-package #:cl-user)
(asdf:defsystem geml
  :description "Gemini Server"
  :author "resttime"
  :depends-on (:usocket
               :cl+ssl)
  :serial t
  :components
  ((:module "src"
    :components ((:file "server"))))
  )
