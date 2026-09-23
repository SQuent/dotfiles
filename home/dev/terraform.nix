{ ... }:
# terraform/terragrunt binaries come from mise (config/mise/*.toml), not Nix.
{
  programs.zsh.shellAliases = {
    tg = "terragrunt";
    tgi = "terragrunt init";
    tgp = "terragrunt plan";
    tga = "terragrunt apply";
    tgd = "terragrunt destroy";
    # `hclfmt` is terraform's `fmt` for terragrunt, and is recursive already.
    # (Renamed `hcl fmt` in terragrunt >= 0.78 — this pins 0.54.8.)
    tgfmt = "terragrunt hclfmt";
    cctg = ''find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;'';

    # Whole-stack variants: tg + a(ll) + command. `tgall` keeps a generic
    # prefix for the rarer commands (`tgall output`, `tgall validate`); it
    # can't be `tga`, which is already the single-module apply.
    tgall = "terragrunt run-all";
    tgai = "terragrunt run-all init";
    tgap = "terragrunt run-all plan";
    tgaa = "terragrunt run-all apply";
    tgad = "terragrunt run-all destroy";
    tf = "terraform";
    tfi = "terraform init --upgrade";
    tfp = "terraform plan";
    tfa = "terraform apply";
    tfd = "terraform destroy";
    tffmt = "terraform fmt";
  };
}
