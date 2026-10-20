let provider;
let signer;

const FACTORY_ADDRESS =
"0xEC4dE23B797c52125c3A4977236Aa533939B25BB";

const FACTORY_ABI = [
  "function createCampaign(string,string,string,uint256,uint256)",
  "function getCampaigns() view returns(address[])"
];

document
.getElementById("connect")
.onclick = async () => {

   provider =
   new ethers.BrowserProvider(window.ethereum);

   await provider.send(
   "eth_requestAccounts",
   []
   );

   signer =
   await provider.getSigner();

   alert("Wallet Connected");
};

document
.getElementById("createCampaign")
.onclick = async () => {

  const factory =
  new ethers.Contract(
      FACTORY_ADDRESS,
      FACTORY_ABI,
      signer
  );

  const title =
      document.getElementById("title").value;

  const desc =
      document.getElementById("description").value;

  const image =
      document.getElementById("image").value;

  const goalETH =
      document.getElementById("goal").value;

  const days =
      document.getElementById("days").value;

  const tx =
      await factory.createCampaign(
          title,
          desc,
          image,
          ethers.parseEther(goalETH),
          days
      );

  await tx.wait();

  alert("Campaign Created");
};
