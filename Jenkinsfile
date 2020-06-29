node {
    def app

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
    sh '''
            echo "Execute the deployment"
            kubectl get namespace smallcase-demo
            if [ $? -eq 0 ]; then
              echo "namespace smallcase-demo already exists"
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
    }
}
