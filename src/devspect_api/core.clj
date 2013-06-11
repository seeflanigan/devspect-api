(ns devspect-api.core
  (:require [compojure.core :refer :all]
            [ring.adapter.jetty :refer :all]
            [compojure.route :as route]
            [compojure.handler :as handler]
            [clojure.java.jdbc :as jdbc]
            [clojure.java.jdbc.sql :as sql]
            [clojure.string :as str]
            [clojure.data.xml :as xml]))

(defn parse-dt [input]
  (let [local-dt-fmt (java.text.SimpleDateFormat. "yyyy/MM/dd HH:mm:ss zzz")]
    (->
      (.parse local-dt-fmt input)
      (.getTime)
      (java.sql.Timestamp. ))))

(defn get-attribute [key ds]
  (->> ds
       (tree-seq :content :content)
       (filter #(= key (:tag %)))
       (first)
       (:content)
       (first)))

(defn author-name [ds] (get-attribute :author ds))
(defn description [ds] (get-attribute :description ds))
(defn occurred-at [ds] (parse-dt (get-attribute :occurred_at ds)))
(defn activity-type [ds] (get-attribute :event_type ds))
(defn project-id [ds] (Integer. (get-attribute :project_id ds)))

(def db
  {:subprotocol "postgresql"
   :subname "//127.0.0.1:5432/devspect-api" })

(defn handle-pivotal-post [xml]
  (let [ds (xml/parse-str xml)]
    (jdbc/insert! db :pivotal_tracker
       {:author_name (author-name ds)
        :description (description ds)
        :occurred_at (occurred-at ds)
        :activity_type (activity-type ds)
        :project_id (project-id ds)
       }))
  "OK")

(defroutes my-routes
  (GET "/" [] "this is compojure")
  (POST "/pivotal-tracker" {body :body} (handle-pivotal-post body))
  (route/not-found "fore oh fore"))

(def app (handler/site my-routes))

