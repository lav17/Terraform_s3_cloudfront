pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('f69d8b70-3d94-4abe-90c8-9cb608f1a66b')
        AWS_SECRET_ACCESS_KEY = credentials('f69d8b70-3d94-4abe-90c8-9cb608f1a66b')
    }

    stages {
        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'f69d8b70-3d94-4abe-90c8-9cb608f1a66b',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    script {
                        bat """
                            terraform init \
                                -var AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID} \
                                -var AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY} \
                            """
                    }
                }
            }
        }

        

        stage('Terraform Destroy') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'f69d8b70-3d94-4abe-90c8-9cb608f1a66b',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    script {
                        bat """
                            terraform destroy \
                                -var AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID} \
                                -var AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY} \
                                -auto-approve
                            """
                    }
                }
            }
        }
        
    
    }
}
