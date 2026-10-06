pipeline {
    agent any

    stages {

        stage('代码检出') {
            steps {
                echo 'nova-cloud 代码检出成功'
                sh 'pwd'
                sh 'git log -1 --oneline'
            }
        }

        stage('Maven环境检查') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
            }
        }

        stage('Maven打包') {
            steps {
                sh '''
                    mvn clean package -DskipTests
                '''
            }
        }
    }

    post {
        success {
            echo 'nova-cloud Maven 构建成功'
        }

        failure {
            echo 'nova-cloud Maven 构建失败'
        }
    }
}