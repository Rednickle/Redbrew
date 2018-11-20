class Ethereum < Formula
  desc "Official Go implementation of the Ethereum protocol"
  homepage "https://ethereum.github.io/go-ethereum/"
  url "https://github.com/ethereum/go-ethereum/archive/v1.8.18.tar.gz"
  sha256 "cbab18a733298830c9ed1e19c1ece37edf417fd55ec8f198803048ecc3ffa0b9"
  head "https://github.com/ethereum/go-ethereum.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "04085911ae9c4f79dec01e0a850c2df1e66bc2544b94484c030356e738b6776c" => :mojave
    sha256 "c69281c843d092c5bef17191645a07feb3f6f7525e38e40287beea109b0252cc" => :high_sierra
    sha256 "b7d7cceeb2db0dedca84e2661402491eac440614542baf3c547bd2302e99fa6c" => :sierra
    sha256 "e93f91b0bc722ca05d818d4992c2c9bf8bc9834b58643400ee0711ad7c1f81eb" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV.O0 unless OS.mac? # See https://github.com/golang/go/issues/26487
    system "make", "all"
    bin.install Dir["build/bin/*"]
  end

  test do
    (testpath/"genesis.json").write <<~EOS
      {
        "config": {
          "homesteadBlock": 10
        },
        "nonce": "0",
        "difficulty": "0x20000",
        "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
        "coinbase": "0x0000000000000000000000000000000000000000",
        "timestamp": "0x00",
        "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "extraData": "0x",
        "gasLimit": "0x2FEFD8",
        "alloc": {}
      }
    EOS
    system "#{bin}/geth", "--datadir", "testchain", "init", "genesis.json"
    assert_predicate testpath/"testchain/geth/chaindata/000001.log", :exist?,
                     "Failed to create log file"
  end
end
