{ ... }:
{
    services.knot-resolver = {
        enable = true;
        settings = {
            network.listen = [
                {
                    interface = [ "128.254.224.230" ];
                    kind = "dns";
                    freebind = false;
                }
            ];
        };
    };

    allowedTCPPorts = [ 53 ];
}