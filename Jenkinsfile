pipeline {
    agent any
    
    parameters {
        choice(name:"terraform", choices:["apply","destroy"])
    }
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }
    stages {
        stage('Git Checkout') {
            steps {
               git branch: 'Dev', credentialsId: 'Github_token', url: 'https://github.com/GeethikaTadisetty/Terraform-project.git'
            }
                
        }
        stage('Terraform init') {
            steps {
               dir('EKSProject') { 
                   sh 'terraform init'
               }
            }
        }
        stage('Terraform plan') {
            steps {
                dir('EKSProject') {
                    sh 'terraform plan'
                }
            }
        }
        stage('Terraform apply') {
            steps {
                dir('EKSProject') {
                    script {
                        if(params.terraform == "apply"){
                        sh 'terraform apply --auto-approve'
                    }
                    else if(params.terraform == "destroy") {
                        sh 'terraform destroy --auto-approve'
                    }
                   }
                    
                }
            }
        }
    }
}
