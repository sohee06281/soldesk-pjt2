resource "aws_security_group" "lambda-sg" {
  name   = "${var.project_name}-lambda-sg"
  vpc_id = aws_vpc.this.id

  # ❌ ingress 필요 없음 (Lambda는 외부에서 직접 접근 X)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
