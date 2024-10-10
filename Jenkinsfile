pipeline {
    agent any

    tools {
        maven 'maven'
        nodejs 'nodejs'
    }

    stages {
        stage('Build Angular') {
            steps {
                git branch: 'master', url: 'https://github.com/brahgithubsal/angular.git'
            }
        }
        stage('Frontend File System Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        stage("SonarQube Analysis NPM"){
           steps {
	           script {
		        withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') {
		                sh "npm install --save-dev sonarqube-scanner"
                        sh "npm run sonar-scanner"
		        }
	           }	
           }
       }


        stage('Build Angular Docker image') {
            steps {
                script {
                    sh 'docker build -t azizbk9/angular-image .'
                }
            }
        }
        stage('Scan Angular Docker image') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html azizbk9/angular-image "
            }
        }


        stage('Push Angular image to Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'dockerhubpwd')]) {
                        sh 'docker login -u azizbk9 -p ${dockerhubpwd}'
                        sh 'docker push azizbk9/angular-image'
                    }
                }
            }
        }

        stage('Build Spring Boot Maven') {
            steps {
                git branch: 'master', url: 'https://github.com/brahgithubsal/SPRING-BOOT.git'
            }
        }
        stage('Backend File System Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        stage("SonarQube Analysis Maven"){
           steps {
	           script {
		        withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') { 
                        sh "mvn sonar:sonar"
		        }
	           }	
           }
       }

        stage('Build Spring Boot Docker image') {
            steps {
                script {
                    sh 'docker build -t azizbk9/spring-image .'
                }
            }
        }
        stage('Scan Spring Boot Docker image') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html azizbk9/spring-image "
            }
        }


        stage('Push Spring Boot image to Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'dockerhubpwd')]) {
                        sh "echo \$dockerhubpwd | docker login -u azizbk9 --password-stdin"
                        sh 'docker push azizbk9/spring-image'
                    }
                }
            }
        }
    }
}
