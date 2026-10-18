pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = '922364862424.dkr.ecr.ap-south-1.amazonaws.com/nexvion'
        IMAGE_TAG = "${BUILD_NUMBER}"
        
    }

    stages {
        stage('Checkout') {
            steps {
                git url: "https://github.com/MeerajaMohandas/Davine_Nexvion.git" , branch : "main"
            }
        }
        
        stage('Build Docker image') {
            steps {
                sh '''
                    docker build -t devopsmeeraja/nexvion:${BUILD_NUMBER} .
                
                '''
                
                
            }
            
        }
        
        stage('Testing docker image') {
            steps {
                sh '''
                    docker rm -f nexvion-test || true
                
                    docker run -d \
                    --name nexvion-test \
                    -p 127.0.0.1:8088:80 \
                    devopsmeeraja/nexvion:${BUILD_NUMBER}
                    
                    sleep 5
                    
                    curl -f http://127.0.0.1:8088
                    
                '''
                
            }
            
        }
        
    /*    stage('Trivy security scan') {
            steps{
                sh '''
                trivy image --severity HIGH,CRITICAL --exit-code 1 devopsmeeraja/nexvion:${BUILD_NUMBER}
                
                '''
                
            }
            
        }*/
        
        stage('Push to ECR') {
            steps{
                
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-ecr-jenkins'
                        ]
                    ]) {
                sh '''
                 aws ecr get-login-password --region ${AWS_REGION} | \
                 docker login --username AWS --password-stdin \
                 922364862424.dkr.ecr.ap-south-1.amazonaws.com
                 
                 docker tag devopsmeeraja/nexvion:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                 
                 docker push ${ECR_REPO}:${IMAGE_TAG}
                 
                '''
                    }
            }
            
        }
        
        
        
stage('Deploy with Helm') {
    steps {
        sh '''
            set -e

            echo "Deploying Nexvion image: ${ECR_REPO}:${IMAGE_TAG}"

            helm upgrade --install nexvion-helm \
              /home/ubuntu/nexvion-helm/nexvion \
              --namespace default \
              --set image.repository=${ECR_REPO} \
              --set image.tag=${IMAGE_TAG} \
              --wait \
              --timeout 5m

            kubectl rollout status deployment/nexvion-helm \
              --namespace default \
              --timeout=300s

            kubectl get pods
            kubectl get svc nexvion-helm-service
        '''
    }
}

        
        stage('Cleanup') {
            steps{
                sh '''
                    docker rm -f nexvion-test || true
                '''
                
            }
            
        }
        
        
stage('Check DevOps Tools') {
    steps {
        sh '''
            echo "=== Jenkins user ==="
            whoami
            echo "=== Current directory ==="
            pwd

            echo "=== Tool versions ==="
            terraform version
            ansible --version
            helm version --short
            kubectl version --client

            echo "=== Project directories ==="
            ls -ld /home/ubuntu/nexvion-terraform
            ls -ld /home/ubuntu/ansible-nexvion
            ls -ld /home/ubuntu/nexvion-helm/nexvion
        '''
    }
}
    
/*stage('Terraform Validate') {
    steps {
        withCredentials([
            [$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-ecr-jenkins']
        ]) {
        dir('/home/ubuntu/nexvion-terraform') {
            sh '''
                terraform fmt -check
                terraform init -backend=false
                terraform validate
                terraform plan -input=false
            '''
        }
    }


}

    }
    */
    
stage('Ansible Connection Check') {
    steps {
        
            sh '''
                ansible k3s_servers \
              -i /home/ubuntu/ansible-nexvion/inventory.ini \
              -m ping
            '''
    }
    }
}

}


