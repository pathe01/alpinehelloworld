pipeline {
    environment {
        ID_DOCKER = "${ID_DOCKER_PARAMS}"
        IMAGE_NAME = "alpinehelloworld"                    /*alpinehelloworld par exemple*/
        //APP_EXPOSED_PORT = "${PARAM_PORT_EXPOSED}"            /*80 par défaut*/
        APP_NAME = "pathe"                        /*eazytraining par exemple*/
        IMAGE_TAG = "latest"                      /*tag docker, par exemple latest*/ 
        //STAGING = "${PARAM_APP_NAME}-staging"
        //PRODUCTION = "${PARAM_APP_NAME}-prod"
       //ID_DOCKER = "${PARAM_ID_DOCKER}"
        DOCKERHUB_PASSWORD = credentials('dockerhub_pathe01')
        STG_API_ENDPOINT = "192.168.56.11:1993"        /* Mettre le couple IP:PORT de votre API eazylabs, exemple 100.25.147.76:1993 */
        STG_APP_ENDPOINT = "192.168.56.11:8000"        /* Mettre le couple IP:PORT votre application en staging, exemple 100.25.147.76:8000 */
        PROD_API_ENDPOINT = "192.168.56.11:1993"       /* Mettre le couple IP:PORT de votre API eazylabs, 100.25.147.76:1993 */
        PROD_APP_ENDPOINT = "192.168.56.11"            /* Mettre le couple IP:PORT votre application en production, exemple 100.25.147.76 */
        INTERNAL_PORT = "5000"     /*5000 par défaut*/
        //INTERNAL_PORT = "${PARAM_INTERNAL_PORT}"      /*5000 par défaut*/
        EXTERNAL_PORT = "${PORT_EXPOSED}"
        CONTAINER_IMAGE = "${ID_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    /*parameters {
        // booleanParam(name: "RELEASE", defaultValue: false)
        // choice(name: "DEPLOY_TO", choices: ["", "INT", "PRE", "PROD"])
        string(name: 'PARAM_IMAGE_NAME', defaultValue: 'alpinehelloworld', description: 'Image Name')
        string(name: 'PARAM_PORT_EXPOSED', defaultValue: '80', description: 'APP EXPOSED PORT')        
    }*/
    agent none
    stages {
       stage('Build image') {
           agent any
           steps {
              script {
                sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
              }
           }
       }
       stage('Run container based on builded image') {
          agent any
          steps {
            script {
              sh '''
                  echo "Cleaning existing container if exist"
                  docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                  docker run --name $IMAGE_NAME -d -p $PORT_EXPOSED:$INTERNAL_PORT  -e PORT=$INTERNAL_PORT ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                  sleep 5
              '''
             }
          }
       }
       stage('Test image') {
           agent any
           steps {
              script {
                sh '''
                   curl -v 172.17.0.1:$PORT_EXPOSED | grep -q "Hello world!"
                '''
              }
           }
       }
       stage('Clean container') {
          agent any
          steps {
             script {
               sh '''
                   docker stop $IMAGE_NAME
                   docker rm $IMAGE_NAME
               '''
             }
          }
      }

      stage ('Login and Push Image on docker hub') {
          agent any
          steps {
             script {
               sh '''
                   echo $DOCKERHUB_PASSWORD_PSW | docker login -u $DOCKERHUB_PASSWORD_USR --password-stdin
                   docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
               '''
             }
          }
      }

      stage('STAGING - Deploy app') {
      agent any
      steps {
          script {
            sh """
              echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
              curl -v -X POST http://${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
            """
          }
        }
     
     }
     stage('PROD - Deploy app') {
       when {
           expression { GIT_BRANCH == 'origin/eazylabs' }
       }
     agent any

       steps {
          script {
            sh """
              echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
              curl -v -X POST http://${PROD_API_ENDPOINT}/prod -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
            """
          }
       }
     }
  }
}
