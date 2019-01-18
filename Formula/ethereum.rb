class Ethereum < Formula
  desc "Official Go implementation of the Ethereum protocol"
  homepage "https://ethereum.github.io/go-ethereum/"
  url "https://github.com/ethereum/go-ethereum/archive/v1.8.21.tar.gz"
  sha256 "736028b4babd44d67a70a4a7883a06e97263449805c8c067b7dfd77e9fa94299"
  head "https://github.com/ethereum/go-ethereum.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "088a8f9f6f35433e66c2b6ad8dadfcbb0c25b8d3cbbbee2aba5020566c6709fd" => :mojave
    sha256 "0a4fd03dc6151d5f3453192bca228cbcad425130be21e44c987596956e172746" => :high_sierra
    sha256 "7be903f50774d4bea67b7e464033f22f53478f94266c2dd96c618310bf93d4a7" => :sierra
    sha256 "8de25637331a836d56bb6c70afc1b5bf1afa875a4e7c40656a76c39a3219c6b7" => :x86_64_linux
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
