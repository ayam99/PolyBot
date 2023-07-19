// @Library('shared-lib-int') _

// library 'shared-lib-int@main'

pipeline {
    options {
	buildDiscarder logRotator( artifactNumToKeepStr: '10', numToKeepStr: '10')
        disableConcurrentBuilds()
	timestamps()
        timeout(time: 5, unit: 'MINUTES')
    }

    agent {
        kubernetes {
            
            // label 'mypod-label'
            defaultContainer 'jenkins-agent'
	    cloud 'EKS'

            yaml '''
              apiVersion: v1
              kind: Pod
              metadata:
               labels:
                  some-label: mypod-label
              spec:
                serviceAccountName: jenkins-admin
                containers:
                - name: jenkins-agent
                  image: 019273956931.dkr.ecr.eu-west-1.amazonaws.com/ayam-ecr-repo:jenkins2
                  imagePullPolicy: Always
                  volumeMounts:
                  - name: jenkinsagent-pvc
                    mountPath: /var/run/docker.sock
                  tty: true
                volumes:
                - name: jenkinsagent-pvc
                  hostPath:
                    path: /var/run/docker.sock
                securityContext:
                  allowPrivilegeEscalation: false
                  runAsUser: 0
            '''
        }
    }

    environment {
        SNYK_TOKEN = credentials('snyk-token')
    }

    stages {
        stage('Test') {
            parallel {
                stage('pytest') {
                    steps {
                        withCredentials([file(credentialsId: 'telegramToken', variable: 'TELEGRAM_TOKEN')]) {
                            sh "cp ${TELEGRAM_TOKEN} .telegramToken"
                            sh 'pip3 install -r requirements.txt'
                            sh "python3 -m pytest --junitxml results.xml tests/*.py"
                        }
                    }
                }
                stage('pylint') {
                    steps {
                        script {
                            echo 'Starting'
                            echo 'Nothing to do!'
                            sh "python3 -m pylint *.py || true"
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
              sh "docker build -f /home/ec2-user/PolyBot/Dockerfile -t ayam-ecr-repo ."
              sh "docker tag ayam-ecr-repo:latest 019273956931.dkr.ecr.eu-west-1.amazonaws.com/ayam-ecr-repo:latest"           
            }
        }

        stage('push') {
            steps {
               withAWS(credentials: 'AWS-Credentials', region: 'eu-west-1') {
                   sh "docker push ayam-ecr-repo:latest 019273956931.dkr.ecr.eu-west-1.amazonaws.com/ayam-ecr-repo:latest"
               }
            }
        }
        
        stage('Publish SNS') {
            steps {
                echo 'Publishing SNS message to AWS'
                withAWS(credentials: 'AWS-Credentials', region: 'eu-west-1') {
                    snsPublish(
                        topicArn: 'arn:aws:sns:eu-west-1:019273956931:ayam-topic',
                        subject: "${params.ACTION} ${params.AWS_ENVIRONMENT}",
                        message: getMessage(mapEnvironmentToAWS[params.AWS_ENVIRONMENT], params.ACTION)
                    )
                }
            }
        }
    }
	post {
           always {
             junit allowEmptyResults: true, testResults: 'results.xml'
        }
    }


}
