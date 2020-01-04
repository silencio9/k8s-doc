


上线模版
```
def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'maven', image: 'maven:3.3.9-jdk-8-alpine', ttyEnabled: true, command: 'cat')
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    stage('Get a Maven Project') {
        git branch: 'master',credentialsId: 'xxxx',url: 'https://xxxxxx.git'
        container('maven') {
                stage('Build a Maven project') {
                    sh 'mvn -B clean install -DskipTests=true'
                }
            }
    }
    stage('Create Docker images') {
      container('docker') {
          sh """
            docker login -u admin
            """

      }
    }
  }
}
```
