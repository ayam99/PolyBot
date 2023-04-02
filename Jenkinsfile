// This line specifies that this pipeline uses the shared library 'shared-lib-int'.
// @Library('shared-lib-int') _

// This line loads the 'main' branch of the 'shared-lib-int' library.
library 'shared-lib-int@main'


pipeline {
    
  // This block sets the options for the pipeline. It sets a build discarder strategy to keep only 10 builds for the last 5 days, and it disables concurrent builds.
    options{
         buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '5', numToKeepStr: '10'))
         disableConcurrentBuilds()
    }
    
    // This block sets the options for the pipeline. It sets a build discarder strategy to keep only 10 builds for the last 5 days, and it disables concurrent builds.
    agent {
      docker {
        image 'jenkins-agent:latest'
        args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    // This line sets an environment variable 'SNYK_TOKEN' to the value of the 'snyk-token' credential.
    environment{
        SNYK_TOKEN = credentials('snyk-token')
    }
    
    stages {

        stage('Test') {
            // parallel stages
            parallel {
                
                // pytest copies the 'telegramToken' credential file, installs dependencies from the 'requirements.txt' file, and runs the tests using Pytest.
                stage('pytest') {
                    steps {
                        withCredentials([file(credentialsId: 'telegramToken', variable: 'TELEGRAM_TOKEN')]) {
                        sh "cp ${TELEGRAM_TOKEN} .telegramToken"
                        sh 'pip3 install -r requirements.txt'
                        sh "python3 -m pytest --junitxml results.xml tests/*.py"
                        }
                    }
                }
                // Run the Pylint linter
                stage('pylint') {
                    steps {
                        script {
                            logs.info 'Starting'
                            logs.warning 'Nothing to do!'
                            sh "python3 -m pylint *.py || true"
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                
                // Uses the 'docker-hub-credentials' credential to build a Docker image with the 'docker build' command.
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'pass', usernameVariable: 'user')]) {
                    
                 // Tag the docker image with the build number.
                 sh "docker build -t ayamb99/polybot:poly-bot-${env.BUILD_NUMBER} . "
                 // Logs into the Docker registry with the credentials.
                 sh "docker login --username $user --password $pass"
  //              sh '''
 //               docker login --username $user --password $pass
 //               docker build ...
 //               docker tag ...
 //               docker push ...
 //          '''
       
            }
         }
      }
        
        // run the Snyk-test tool to test the Docker image for vulnerabilities.
        stage('snyk test') {
            steps {
                sh "snyk container test --severity-threshold=critical ayamb99/polybot:poly-bot-${env.BUILD_NUMBER} --file=Dockerfile"
            }
        }
        
        stage('push') {
            steps {
                // Pushes an image to a Docker registry
                sh "docker push ayamb99/polybot:poly-bot-${env.BUILD_NUMBER}"
            }
         }
    }
    
    post {
        always {
            
            // The junit step will look for a JUnit test results file called results.xml and display the results in the Jenkins build report.
            // The allowEmptyResults parameter is set to true to ensure that even if no test results are found, the pipeline run will still succeed.
            junit allowEmptyResults: true, testResults: 'results.xml'
            
            // Remove any unused Docker images that were created during the build process
            sh 'docker image prune -f' // Clean the build artifacts from Jenkins server
            
               }
          }
    
}
