# Purpose
This repository contains a deployment of the banking application. In previous implementations, I deployed the application on the same instance as the Jenkins Build. In this deployment, I deployed the application on two different instances simultaneously using Jenkin's agents. Deploying an application using a Jenkins agent improves performance and enhances security.


# Issues
I received the following error when launching the Jenkins agent on the application server.
  * java.lang.InterruptedException: Validate configuration:
  * The selected credentials cannot be found
The ssh could not find the expected credentials because I did not copy the private key correctly. Once I placed the correct private key in the Jenkins agent configurations, the agent launched successfully.

# Steps
1. Create a private key pair in AWS
2. Create a VPC with the following resources: 2 public subnets, security groups, 1 route table, and 3 EC2 instances.
3. Install Jenkins on a separate instance and install the following dependencies:
   - software-properties-common(helps you add and remove PPA, otherwise you will have to add them to your source list manually), sudo add-apt-repository -y ppa:deadsnakes/ppa(allows you to use different versions of pythons), python3.7, python3.7-venv}
   - Install the following plugin: “Pipeline Keep Running Step”
4. Install the following dependencies on the other 2 instances that will store your application
   - Install the following: {default-jre, software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, python3.7, python3.7-        venv}
5. Configure two agents on your Jenkins server to be launched on each application server.
6. Run the Jenkins build
<img width="1065" alt="Screen Shot 2023-10-20 at 2 02 39 PM" src="https://github.com/DarrielleEvans/Deployment5_1/assets/89504317/7d0fb721-f50d-46b9-bff3-b977ed725a86">

8. Verify the application runs on port 8000
<img width="1405" alt="Screen Shot 2023-10-20 at 2 05 07 PM" src="https://github.com/DarrielleEvans/Deployment5_1/assets/89504317/2408750b-a702-4d8f-9d98-60910d1a1486">


# System Diagram
![dp5-1 drawio (1)](https://github.com/DarrielleEvans/Deployment5_1/assets/89504317/fdca558b-da4e-4bbb-9e72-1c1f68cc63e8)


# Optimization
The application will be more secure by placing the Jenkins server in a private subnet and using endpoint connections to launch the agents on the instances located in public subnets. Isolating your Jenkins server provides an additional layer of security because the server will not be directly accessible by the internet.


# Technologies Used
* Jenkins
* AWS: 3 X T2.Medium Instances, VPC, Security Groups, Route Table, 2 Public Subnets
* Keep it Running Plugin (Jenkins)
* Software Common Properties package(EC2)
* Terraform

# Notes
A load balancer would increase the application's availability for users. 
The Jenkins agent is great for applications that are located across multiple servers. You can distribute the workload across multiple instances and run pipelines simultaneously.
  

