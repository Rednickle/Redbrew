class Xonsh < Formula
  include Language::Python::Virtualenv

  desc "Python-ish, BASHwards-compatible shell language and command prompt"
  homepage "https://xon.sh/"
  url "https://github.com/xonsh/xonsh/archive/0.9.17.tar.gz"
  sha256 "68dbe61edc02776e8fe9ae4e5a73db0a65e00ef89081bcdb7e58f840624f8355"
  head "https://github.com/xonsh/xonsh.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "42cf4efd4db2a8b88ab723f11e5d2945fc14c926d826f371da80b7822008d565" => :catalina
    sha256 "67b01e4a4b291bffc17140a3238f305d6801f36ffecbdbcd5f38506ca41b163f" => :mojave
    sha256 "892bc55f2f35fa443a757326e7f55d10907a5b96c911662d30304eab108cd601" => :high_sierra
    sha256 "9faa9d43b61c0cf0719edfaaa6976a88fb4e7769d1f82599a7a8ccf8e47ab4b2" => :x86_64_linux
  end

  depends_on "python@3.8"

  # Resources based on `pip3 install xonsh[ptk,pygments,proctitle]`
  # See https://xon.sh/osx.html#dependencies

  resource "prompt_toolkit" do
    url "https://files.pythonhosted.org/packages/61/c9/56131b4753ef14bffd06754846c63de78b3a868e995763f6410381a6fb98/prompt_toolkit-3.0.4.tar.gz"
    sha256 "ebe6b1b08c888b84c50d7f93dee21a09af39860144ff6130aadbd61ae8d29783"
  end

  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/6e/4d/4d2fe93a35dfba417311a4ff627489a947b01dc0cc377a3673c00cf7e4b2/Pygments-2.6.1.tar.gz"
    sha256 "647344a061c249a3b74e230c739f434d7ea4d8b1d5f3721bc0f3558049b38f44"
  end

  resource "setproctitle" do
    url "https://files.pythonhosted.org/packages/5a/0d/dc0d2234aacba6cf1a729964383e3452c52096dc695581248b548786f2b3/setproctitle-1.1.10.tar.gz"
    sha256 "6283b7a58477dd8478fbb9e76defb37968ee4ba47b05ec1c053cb39638bd7398"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/21/9f/b251f7f8a76dec1d6651be194dfba8fb8d7781d10ab3987190de8391d08e/six-1.14.0.tar.gz"
    sha256 "236bdbdce46e6e6a3d61a337c0f8b763ca1e8717c03b369e87a7ec7ce1319c0a"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/25/9d/0acbed6e4a4be4fc99148f275488580968f44ddb5e69b8ceb53fc9df55a0/wcwidth-0.1.9.tar.gz"
    sha256 "ee73862862a156bf77ff92b09034fc4825dd3af9cf81bc5b360668d425f3c5f1"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "4", shell_output("#{bin}/xonsh -c 2+2")
  end
end
