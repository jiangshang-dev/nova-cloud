pipeline {
    agent any

    tools {
        maven 'maven3'
    }

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
                    mvn clean package -DskipTests -s /var/jenkins_home/.m2/settings.xml
                '''
            }
        }

        stage('Docker构建镜像') {
            steps {
                sh '''
                    docker build -t nova-nacos:latest ./nova-nacos
                    docker build -t nova-gateway:latest ./nova-platform/nova-gateway
                '''
            }
        }

        stage('启动Nacos') {
            steps {
                sh '''
                    docker rm -f nova-nacos || true

                    docker run -d \
                      --name nova-nacos \
                      --restart=always \
                      -p 8848:8848 \
                      -p 8849:8849 \
                      nova-nacos:latest
                '''
            }
        }

        stage('等待Nacos启动') {
            steps {
                sh '''
                    echo "等待 Nacos 启动..."
                    sleep 15
                '''
            }
        }

        stage('启动容器') {
            steps {
                sh '''
                    docker rm -f nova-gateway || true

                    docker run -d \
                      --name nova-gateway \
                      --restart=always \
                      -p 8080:8080 \
                      nova-gateway:latest
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