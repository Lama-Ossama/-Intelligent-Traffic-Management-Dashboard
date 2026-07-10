"""
Architecture diagram for the Intelligent Traffic Management Dashboard.
Diagram-as-code using the `diagrams` library.

Requirements:
    pip install diagrams
    graphviz installed on the system (brew install graphviz on macOS)

Usage:
    python architecture.py   ->  produces architecture.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.management import Cloudwatch
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.container import Docker
from diagrams.onprem.monitoring import Prometheus
from diagrams.programming.language import Nodejs, Python
from diagrams.onprem.client import Users

graph_attr = {"fontsize": "20", "bgcolor": "white", "pad": "0.5", "splines": "spline"}

with Diagram(
    "Intelligent Traffic Management Dashboard - AWS Deployment",
    filename="architecture",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    users = Users("Users\n(browser)")

    with Cluster("CI/CD Pipeline"):
        github = Github("GitHub repo")
        actions = GithubActions("GitHub Actions")
        github >> Edge(label="push to main") >> actions

    registry = Docker("Docker Hub\n(image registry)")

    with Cluster("AWS EC2 t3.micro (Free Tier)"):
        dashboard = Nodejs("traffic-dashboard\n:80")
        collector = Python("traffic-collector")
        prometheus = Prometheus("Prometheus\n:9090")
        collector >> Edge(label="data") >> dashboard
        prometheus >> Edge(label="scrapes /metrics", style="dashed") >> dashboard

    budget = Cloudwatch("Billing alarm\n+ Zero-spend budget")

    actions >> Edge(label="build & push") >> registry
    registry >> Edge(label="pull images", color="firebrick") >> dashboard
    users >> Edge(label="HTTP", color="darkgreen") >> dashboard
    dashboard >> Edge(style="dotted", color="gray") >> budget
