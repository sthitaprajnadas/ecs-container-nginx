from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS
from diagrams.aws.network import VPC
from diagrams.aws.network import ELB
from diagrams.aws.management import AutoScaling
from diagrams.aws.network import PrivateSubnet
from diagrams.aws.compute import Fargate

with Diagram("Blue Green Deployment + Autoscaling in ECS cluster", show=False):
    with Cluster("VPC"):   
        with Cluster("ECS Cluster"):
            asg = AutoScaling("Autoscaling Policies")
            lb = ELB("ALB")
            with Cluster("AZ1"): 
                # svc_group = [Cluster("Availability Zone")] 
                priv_subnet1 = PrivateSubnet("Private Subnet A")
                with PrivateSubnet("Private Subnet A"):
                    Fargate1 = Fargate("Fargate1")

            with Cluster("AZ2"): 
                # svc_group = [Cluster("Availability Zone")] 
                priv_subnet2= PrivateSubnet("Private Subnet B")
                with PrivateSubnet("Private Subnet B"):
                    Fargate2 = Fargate("Fargate2")

        # svc_group = [ Cluster("AZ1"), Cluster("AZ2") ] 
            lb >> priv_subnet1
            lb >> priv_subnet2

        

            # with Cluster("AZ2"):
            #     priv_subnet2 = PrivateSubnet("Private Subnet B")

            

            