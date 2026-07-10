"""
Architecture diagram for the Intelligent Traffic Management Dashboard.

Diagram-as-code using the `diagrams` library (https://diagrams.mingrammer.com).
Run this script to regenerate architecture.png.

Requirements:
    pip install diagrams
    graphviz must be installed on the system (provides the `dot` binary):
        macOS:   brew install graphviz
        Ubuntu:  sudo apt-get install graphviz
        Windows: choco install graphviz   (or download from graphviz.org)

Usage:
    python architecture.py
    -> produces architecture.png in the same folder
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.management import Cloudwatch
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.container import Docker
from diagrams.onprem.iac import Terraform
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.programming.language import Nodejs, Python
from diagrams.onprem.client import Users

graph_attr = {
    "fontsize": "20",
    "bgcolor": "white",
    "pad": "0.6",
    "splines": "spline",
    "nodesep": "0.6",
    "ranksep": "0.9",
}

with Diagram(
    "Intelligent Traffic Management Dashboard - AWS Deployment",
    filename="architecture",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    users = Users("Users\n(browser)")

    # --- Infrastructure as Code ---
    terraform = Terraform("Terraform\n(provisions infra)")

    # --- CI/CD Pipeline ---
    with Cluster("CI/CD Pipeline (GitHub Actions)"):
        github = Github("GitHub repo")
        actions = GithubActions("Actions\ntest -> build -> deploy")
        registry = Docker("Docker Hub\n(image registry)")

        github >> Edge(label="push to main") >> actions
        actions >> Edge(label="build & push") >> registry

    # --- AWS free-tier host ---
    with Cluster("AWS EC2 t3.micro (Free Tier)"):
        dashboard = Nodejs("traffic-dashboard\n:3002")
        collector = Python("traffic-collector")
        prometheus = Prometheus("Prometheus\n:9090")
        grafana = Grafana("Grafana\n:3000")

        collector >> Edge(label="traffic data") >> dashboard
        prometheus >> Edge(label="scrapes /metrics", style="dashed") >> dashboard
        grafana >> Edge(label="queries", style="dashed") >> prometheus

    # --- Guardrails ---
    budget = Cloudwatch("Billing alarm\n+ Zero-spend budget")

    # --- Flows across the system ---
    terraform >> Edge(label="provisions", color="purple", style="bold") >> dashboard
    actions >> Edge(label="SSH auto-deploy", color="firebrick") >> dashboard
    registry >> Edge(label="images", color="firebrick", style="dashed") >> dashboard
    users >> Edge(label="HTTP", color="darkgreen") >> dashboard
    dashboard >> Edge(style="dotted", color="gray") >> budget
