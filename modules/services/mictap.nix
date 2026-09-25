{
  nixos.services.mictap =
    { pkgs, my, ... }:
    let
      vault = "/srv/data/webdav/max/mictap";
      models = {
        MICTAP_WHISPER_MODEL = pkgs.fetchurl {
          url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin";
          hash = "sha256-OUIhcJzVrR9AxG5gMcphvOiJMebgiMGIKUxtWlX/p+I=";
        };
        MICTAP_VAD_MODEL = pkgs.fetchurl {
          url = "https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin";
          hash = "sha256-KZQNmNQrkfvQXOSJ8+z3xy8KQvAn5IdZGaKPtMBOos8=";
        };
        MICTAP_SEG_MODEL = "${
          pkgs.fetchzip {
            url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-segmentation-models/sherpa-onnx-pyannote-segmentation-3-0.tar.bz2";
            hash = "sha256-hqaCTZJKZp6IHxYzgVBd9Bss6wC1qg+edB/v10BT1tA=";
          }
        }/model.onnx";
        # "recongition" is upstream's spelling of the release tag.
        MICTAP_EMB_MODEL = pkgs.fetchurl {
          url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-recongition-models/3dspeaker_speech_campplus_sv_zh_en_16k-common_advanced.onnx";
          hash = "sha256-qjz8FpY6EFhqk5P1A11ta1fpjTWLNH+AwqML9PAM66I=";
        };
      };
    in
    {
      users.users.mictap = {
        isSystemUser = true;
        group = "mictap";
        extraGroups = [ "webdav" ];
      };
      users.groups.mictap = { };

      systemd.tmpfiles.rules = [
        "d ${vault} 2770 webdav webdav -"
      ];

      # Listens on 0.0.0.0:8765 but the port is not opened: only tailscale0 is trusted.
      systemd.services.mictap-server = {
        description = "mictap transcription server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
          whisper-cpp
          sherpa-onnx
          ffmpeg
        ];
        environment = models // {
          TZ = "Europe/Amsterdam";
        };
        serviceConfig = {
          ExecStart = "${my.pkgs.mictap}/bin/mictap-server";
          User = "mictap";
          Group = "mictap";
          StateDirectory = "mictap";
          # UMask 0002 is for the vault; transcripts, embeddings and audio stay private.
          StateDirectoryMode = "0750";
          Restart = "on-failure";
          RestartSec = 5;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          # Group webdav can read the whole vault; hide all of it but mictap/.
          TemporaryFileSystem = "/srv/data/webdav:ro";
          BindPaths = vault;
          UMask = "0002";
          Nice = 19;
          CPUWeight = 20;
        };
      };
    };
}
