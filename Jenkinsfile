pipline{
	
     environement{

       IMAGE_NAME= "alpinehelloword"
       IMAGE_TAG= "latest"
       STAGING= "infolearn14-staging"
       PRODUCTION= "infolearn-production"

     }

     agent none 

     Stages{
       
       stage('Build image'){
            agent any
            steps{
                script{

                  sh 'docker built -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
         }
         
       stage('Run conteneur'){
            agent any
            steps{
                script{

                  sh '''
                    docker run  -it --name ${IMAGE_NAME} -d -p 80:5000 -e PORT=5000 ${IMAGE_NAME}:${IMAGE_TAG} 
		    '''
                }
            }
         }

         stage('Test image'){
            agent any
            steps{
                script{

                  sh '''
                    curl http://172.17.0.1 | grep -q "Hello world!"
		   '''
                }
            }
         }

         stage('Clean conteneur'){
            agent any
            steps{
                script{

                  sh '''
                   docker stop ${IMAGE_NAME}
                   docker rm  ${IMAGE_NAME}
                   '''
                }
            }
         }

         stage('Push image in staging and deploy it'){

            when{
              expression {GIT_BRANCH == 'origin/master'}
            }
            agent any
            environement{
               HEROKU_API_KEY = credentials('heroku_api_key')
            }
            steps{
               
               sh '''
                 heroku container: login
                 heroku create $STAGING || "echo project is already exist"
                 heroku container: push -a $STAGING web
                 heroku container: release -a $STAGING web
                 '''
            }
         }

          stage('Push image in production and deploy it'){

            when{
              expression {GIT_BRANCH == 'origin/master'}
            }
            agent any
            environement{
               HEROKU_API_KEY = credentials('heroku_api_key')
            }
            steps{
               
               sh '''
                 heroku container: login
                 heroku create $PRODUCTION || "echo project is already exist"
                 heroku container: push -a $PRODUCTION web
                 heroku container: release -a $PRODUCTION web
                 '''
            }
         }

     }

}
