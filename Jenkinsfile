pipeline {

    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '5', numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    agent {
        kubernetes {
            defaultContainer 'jenkins-agent'
            yaml '''
              apiVersion: v1
              kind: Pod
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
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'pass', usernameVariable: 'user')]) {
                    sh "docker build -t ayamb99/polybot:poly-bot-${env.BUILD_NUMBER} ."
                    sh "docker login --username $user --password $pass"
                }
            }
        }

        stage('snyk test') {
            steps {
                sh "snyk container test --severity-threshold=critical ayamb99/polybot:poly-bot-${env.BUILD_NUMBER} --file=Dockerfile"
            }
        }

        stage('push') {
            steps {
                sh "docker push ayamb99/polybot:poly-bot-${env.BUILD_NUMBER}"
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'results.xml'
            sh 'docker image prune -f'
        }
Additionally, make sure to close the `pipeline` block at the end of the Jenkinsfile:

```groovy
    }
}
