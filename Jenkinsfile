node {
    def app
    stage('clean workspace'){
        cleanWs()
    }
    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git_akash', url: 'https://github.com/akki8400/smallcase-task.git']]])
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build("megiakki/smallcase-task")
        echo "${app}"
    }

    stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'python test.py'
        }
    }
    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('https://registry.hub.docker.com', 'DOCKER_AKKI') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
    stage('Update the deployment file'){
     sh "sed -i s/%IMAGE_NO%/${env.BUILD_NUMBER}/g flask-deployment.yaml"
     sh "cat flask-deployment.yaml"
    }
    stage('Deploy the flask app'){
      withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'AKASH_AWS',
              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]){
      sh '''

              export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/lib/jvm/java-11-openjdk-11.0.7.10-1.el8_1.x86_64/bin:/root/bin:/root/bin:/usr/local/bin/aws
              aws configure list-profiles
              curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/kubectl
              chmod +x ./kubectl
              mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
              kubectl version --short --client
              eksctl version

              kubectl get svc
              echo "Execute the deployment"
              kubectl get namespace smallcase-demo
              if [ $? -eq 0 ]; then
                  echo "namespace smallcase-demo already exists"
                  kubectl get all -n smallcase-demo
              else
                  echo "create smallcase-demo namespace"
                  kubectl create namespace smallcase-domo
              fi
              echo "Apply the deployment"
              kubectl apply -f flask-deployment.yaml
              echo "Create the flask service"
              kubectl apply -f flask-service.yaml

              echo "Deployment done successfully"
        '''
    }  }
}
