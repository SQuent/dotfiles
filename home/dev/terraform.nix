{ ... }:
# terraform/terragrunt binaries come from mise.
{
  programs.zsh.shellAliases = {
    tf = "terraform";
    tfi = "terraform init --upgrade";
    tfp = "terraform plan";
    tfa = "terraform apply";
    tfd = "terraform destroy";
    tffmt = "terraform fmt";
    tgfmt = "terragrunt hcl fmt";
    cctg = ''find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;'';

    tg = "terragrunt";
    tgi = "terragrunt run --all init";
    tgp = "terragrunt run --all plan";
    tga = "terragrunt run --all apply";
    tgd = "terragrunt run --all destroy";

  };
}
