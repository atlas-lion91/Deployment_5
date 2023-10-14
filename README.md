# Deploying a Retail Banking Application using Terraform

## Purpose

The primary objective of this deployment was to establish a robust, scalable, and secure infrastructure on AWS for hosting a web application. By leveraging the power of Terraform, an Infrastructure as Code (IaC) tool, the aim was to automate the provisioning of cloud resources, ensuring consistency, repeatability, and efficient infrastructure management.

Several key goals underpinned this deployment:

1. **Automation**: By integrating Jenkins, a leading Continuous Integration/Continuous Deployment (CI/CD) tool, the deployment process aimed to automate the application's build, test, and deployment stages. This not only accelerates the deployment process but also minimizes human errors.

2. **Scalability**: The infrastructure was designed with scalability in mind. By setting up multiple Availability Zones (AZs) and considering future enhancements like load balancers and auto-scaling groups, the deployment ensures that the application can handle varying loads and can be scaled up or down based on demand.

3. **Security**: Security was a paramount concern. From setting up a Virtual Private Cloud (VPC) to ensure network isolation to configuring security groups for precise access control, every step was taken to safeguard the application and its data.

4. **High Availability**: By deploying resources across multiple AZs, the infrastructure aims to achieve high availability. This ensures that even if one AZ faces an outage, the application remains accessible, providing a seamless user experience.

5. **Maintainability**: With the entire infrastructure setup codified using Terraform and deployment processes defined in Jenkinsfiles, the deployment emphasizes maintainability. Any team member can review, modify, or replicate the infrastructure setup, ensuring transparency and collaboration.

In essence, this deployment was not just about setting up an application on the cloud but about doing so in a way that aligns with best practices, ensuring that the application is resilient, secure, and primed for growth.


### Infrastructure Setup with Terraform

**Why Terraform?** Terraform is an Infrastructure as Code (IaC) tool that allows users to define and provision data center infrastructure using a declarative configuration language. It's chosen for its ability to manage complex infrastructure setups and configurations in a repeatable manner.

1. **Virtual Private Cloud (VPC) Configuration**:
   - Created a VPC.
     - **Why?** A VPC provides a private, isolated section of the AWS Cloud where resources can be launched in a defined virtual network. This ensures security and logical separation of the application.
   - Configured 2 Availability Zones (AZs).
     - **Why?** Using multiple AZs ensures high availability and fault tolerance for applications. If one AZ fails, the application remains accessible via the other AZ.
   - Set up 2 Public Subnets.
     - **Why?** Public subnets allow resources within them to communicate directly with the internet, given they have an Elastic IP or Public IP. This is essential for resources like the Jenkins server which needs to be accessed externally.
   - Launched 2 EC2 instances.
     - **Why?** One instance is for Jenkins (CI/CD) and the other for the application. Separating these ensures that the CI/CD processes don't interfere with the running application.
   - Created 1 Route Table.
     - **Why?** Route tables determine where network traffic is directed. Ensuring correct routing is essential for network communication within the VPC.
   - Configured Security Group with the following ports open: 8080, 8000, 22.
     - **Why?** Security groups act as virtual firewalls. Ports 8080 and 8000 might be application-specific ports, while 22 is for SSH access. Only necessary ports should be opened to ensure security.

### Jenkins Configuration on First EC2 Instance

**Why Jenkins?** Jenkins is a popular open-source tool to perform continuous integration and build automation. It's chosen for its versatility, wide range of plugins, and active community support.

1. **Installation**:
   - Installed Jenkins on the first EC2 instance.
     - **Why?** Jenkins automates the non-human part of the software development process, with continuous integration and facilitating technical aspects of continuous delivery.
   
2. **User Setup**:
   - Created a Jenkins user password.
   - Logged into the Jenkins user.
     - **Why?** This is a security measure. Running Jenkins with a dedicated user minimizes potential risks.

3. **SSH Key Configuration**:
   - Generated a public and private key pair.
   - Copied the public key to the second EC2 instance.
     - **Why?** This allows the Jenkins server to securely communicate with the application server without needing a password.

4. **Software Installation**:
   - Installed necessary software under the `ubuntu` user.
     - **Why?** These packages and repositories might be prerequisites for the application or other tools that will be used in the deployment process.

### Configuration on Second EC2 Instance

1. **Software Installation**:
   - Installed necessary software.
     - **Why?** Just like on the first instance, these are essential prerequisites for the application or other deployment-related tools.

### Jenkins Pipeline Configuration

**Why Pipelines?** Jenkins Pipelines provide an easy way to create and manage a series of automation steps. They are defined using a domain-specific language called "Pipeline DSL."

1. **Jenkinsfilev1**:
   - Defined stages for Build, Test, Deploy, and Reminder.
     - **Why?** This structure ensures a clear CI/CD flow: building the application, testing it, deploying it, and then sending reminders or notifications.

2. **Jenkinsfilev2**:
   - Defined stages for Clean and Deploy.
     - **Why?** This might be a simplified flow for specific deployment scenarios, like hotfixes or minor updates.

### Deployment Process

1. Created a Jenkins multibranch pipeline and executed Jenkinsfilev1.
   - **Why?** Multibranch pipelines automatically recognize multiple branches in a repository, allowing for different Jenkinsfiles per branch. This is useful for feature-specific deployments or different deployment strategies.

2. Checked the application on the second EC2 instance.
   - **Why?** It's essential to verify that the application is running as expected after deployment.

3. Made changes to the HTML content.
   - **Why?** This simulates a real-world scenario where application content or features might be updated frequently.

4. Executed the Jenkinsfilev2.
   - **Why?** To deploy the updated content to the application.

### Considerations

- **Decision to Run Jenkinsfilev2**: The decision to run Jenkinsfilev2 was based on the need to deploy the updated HTML content to the application.
  
- **Instance Placement**: It's recommended to place the Jenkins instance in a public subnet and the application instance in a private subnet.
   - **Why?** This ensures that the Jenkins UI is accessible externally, while the application remains secure. A load balancer can route traffic to the application in the private subnet, ensuring it's not directly exposed to the internet.


## Issues Experienced

During the deployment process, several challenges and issues were encountered:

1. **SSH Key Configuration**:
   - **Issue**: Difficulty in copying the public key from the Jenkins server to the application server.
   - **Resolution**: Ensured that the correct permissions were set for the `authorized_keys` file and the `.ssh` directory on the application server.

2. **Jenkins Plugin Compatibility**:
   - **Issue**: Some Jenkins plugins were not compatible with the Jenkins version installed.
   - **Resolution**: Updated Jenkins to the latest version and ensured all plugins were compatible before installation.

3. **Terraform State Management**:
   - **Issue**: Terraform state conflicts when trying to apply infrastructure changes.
   - **Resolution**: Used remote state management with Amazon S3 and DynamoDB for state locking to ensure consistent state management.

4. **Application Connectivity**:
   - **Issue**: The application on the second EC2 instance was not accessible externally.
   - **Resolution**: Verified security group rules and ensured that the necessary ports were open. Also, checked the application logs for any internal errors.

### Optimization Suggestions

1. **Infrastructure as Code (IaC) Enhancements**:
   - Consider using Terraform modules to modularize and reuse common infrastructure components. This can simplify the Terraform code and make it more maintainable.

2. **Jenkins Pipeline Enhancements**:
   - Implement a rollback mechanism in the Jenkins pipeline. In case of deployment failures, this will ensure that the application can be reverted to its previous stable state.
   - Consider using Jenkins shared libraries to reuse common pipeline steps across different Jenkinsfiles.

3. **Security Enhancements**:
   - Implement a bastion host or a jump server to access the private EC2 instances. This adds an additional layer of security.
   - Regularly rotate SSH keys and use AWS Key Management Service (KMS) for enhanced key management.

4. **Monitoring and Logging**:
   - Integrate CloudWatch or another monitoring tool to monitor the health and performance of EC2 instances.
   - Set up centralized logging using tools like ELK Stack (Elasticsearch, Logstash, Kibana) or Graylog to have a consolidated view of logs from all instances.

5. **Cost Optimization**:
   - Consider using EC2 Spot Instances for non-critical environments to save costs.
   - Regularly review and terminate unused resources to avoid incurring unnecessary costs.


## Conclusion

The deployment process outlined in this documentation represents a comprehensive approach to setting up a web application on AWS. By leveraging modern tools like Terraform and Jenkins, the deployment not only automated the provisioning and deployment processes but also ensured that the infrastructure is scalable, secure, and maintainable.

Throughout the deployment, several challenges were encountered, from SSH key configurations to Terraform state management. However, with diligent troubleshooting and adherence to best practices, these issues were resolved, underscoring the importance of thorough planning and testing in any deployment process.

The optimization suggestions and the purpose behind each step provide a roadmap for future enhancements and deployments. They emphasize the importance of continuous improvement in the ever-evolving landscape of cloud infrastructure and application deployment.

In conclusion, this deployment serves as a testament to the power of automation and the importance of a well-thought-out infrastructure design. As the application grows and evolves, the foundations laid out in this deployment will ensure that it remains resilient, performant, and ready to meet future challenges.
