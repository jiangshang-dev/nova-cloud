pipeline {
    agent any

    stages {
        stage('测试') {
            steps {
                echo 'Jenkins Pipeline 启动成功'
            }
        }

        stage('查看代码') {
            steps {
                sh 'pwd'
                sh 'ls -la'
            }
        }
    }
}