{config,...}:

{
  services.nomad = {
    enable = true;
    enableDocker = false;
    settings = {
      # A minimal config example:
      server = {
        enabled = true;
        bootstrap_expect = 1; # for demo; no fault tolerance
      };
    };
  };
}
