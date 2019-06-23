// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2014 The Bitcoin developers
// Copyright (c) 2014-2015 The Dash developers
// Copyright (c) 2015-2017 The PIVX developers 
// Copyright (c) 2018 The TDC developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "chainparams.h"

#include "random.h"
#include "util.h"
#include "utilstrencodings.h"
#include "base58.h"

#include <assert.h>

#include <boost/assign/list_of.hpp>


using namespace std;
using namespace boost::assign;

struct SeedSpec6 {
    uint8_t addr[16];
    uint16_t port;
};

#include "chainparamsseeds.h"

static CBlock CreateGenesisBlock(const char* pszTimestamp, const CScript& genesisOutputScript, uint32_t nTime, uint32_t nNonce, uint32_t nBits, int32_t nVersion, const CAmount& genesisReward)
{
    CMutableTransaction txNew;
    txNew.nVersion = 1;
    txNew.vin.resize(1);
    txNew.vout.resize(1);
    txNew.vin[0].scriptSig = CScript() << 486604799 << CScriptNum(4) << std::vector<unsigned char>((const unsigned char*)pszTimestamp, (const unsigned char*)pszTimestamp + strlen(pszTimestamp));
    txNew.vout[0].nValue = genesisReward;
    txNew.vout[0].scriptPubKey = genesisOutputScript;

    CBlock genesis;
    genesis.nTime    = nTime;
    genesis.nBits    = nBits;
    genesis.nNonce   = nNonce;
    genesis.nVersion = nVersion;
    genesis.vtx.push_back(txNew);
    genesis.hashPrevBlock.SetNull();
    genesis.hashMerkleRoot = genesis.BuildMerkleTree();
    return genesis;
}

static CBlock CreateGenesisBlock(uint32_t nTime, uint32_t nNonce, uint32_t nBits, int32_t nVersion, const CAmount& genesisReward)
{
    const char* pszTimestamp = "launch blockchain";
	const CScript genesisOutputScript = CScript() << ParseHex("04e928b57880e492fdd2f0cdfd45b52b078a32a5282b4784202ac53b1299837e271f780192a8b014d33b51a6f8bbfc4cfaa3385829452bec7b77bf2f8f97520526") << OP_CHECKSIG;
    return CreateGenesisBlock(pszTimestamp, genesisOutputScript, nTime, nNonce, nBits, nVersion, genesisReward);
}

static void convertSeed6(std::vector<CAddress>& vSeedsOut, const SeedSpec6* data, unsigned int count)
{

    const int64_t nOneWeek = 7 * 24 * 60 * 60;
    for (unsigned int i = 0; i < count; i++) {
        struct in6_addr ip;
        memcpy(&ip, data[i].addr, sizeof(ip));
        CAddress addr(CService(ip, data[i].port));
        addr.nTime = GetTime() - GetRand(nOneWeek) - nOneWeek;
        vSeedsOut.push_back(addr);
    }
}


static Checkpoints::MapCheckpoints mapCheckpoints =
    boost::assign::map_list_of
		(0, uint256("0x000005bf455627f9a90f76775ba78b1bec3266bb32bd839d0b355f00ce8998ad"))
		;
static const Checkpoints::CCheckpointData data = {
    &mapCheckpoints,
    1547107989, 
    0,    
                
    2000       
};

static Checkpoints::MapCheckpoints mapCheckpointsTestnet =
    boost::assign::map_list_of(0, uint256("0x"));
static const Checkpoints::CCheckpointData dataTestnet = {
    &mapCheckpointsTestnet,
    0,
    0,
    250};

static Checkpoints::MapCheckpoints mapCheckpointsRegtest =
    boost::assign::map_list_of(0, uint256("0x"));
static const Checkpoints::CCheckpointData dataRegtest = {
    &mapCheckpointsRegtest,
    0,
    0,
    100};

class CMainParams : public CChainParams
{
public:
    CMainParams()
    {
        networkID = CBaseChainParams::MAIN;
        strNetworkID = "main";

        pchMessageStart[0] = 0xA1;
        pchMessageStart[1] = 0x31;
        pchMessageStart[2] = 0xC2;
        pchMessageStart[3] = 0xA1;
        vAlertPubKey = ParseHex("04266db20be5c53b93678e2e41c9def7af38197280c65e813f682adf2ed501ac186022562dbdf2ce3204d07432660fb61ecad8e78b6b8d39c568fb892db8ecb736");
        nDefaultPort = 17281;
        bnProofOfWorkLimit = ~uint256(0) >> 20;
		
        nSubsidyHalvingInterval = 210000;
        nMaxReorganizationDepth = 100;
        nEnforceBlockUpgradeMajority = 750;
        nRejectBlockOutdatedMajority = 950;
        nToCheckBlockUpgradeMajority = 1000;
        nMinerThreads = 0;
        nTargetTimespan = 1 * 60;
        nTargetSpacing = 1 * 60;
        nLastPOWBlock = 400;
        nMaturity = 101;
        nMasternodeCountDrift = 20;
        nMasternodeColleteralLimxDev = 5000;
        nModifierUpdateBlock = 1;
        nMaxMoneyOut = 300000000 * COIN;
		
        genesis = CreateGenesisBlock(1547107989, 21114322, 0x1e0ffff0, 1, 0 * COIN);

        hashGenesisBlock = genesis.GetHash();

        assert(hashGenesisBlock == uint256("0x000005bf455627f9a90f76775ba78b1bec3266bb32bd839d0b355f00ce8998ad"));
        assert(genesis.hashMerkleRoot == uint256("0x2e5e99f5129fb2b564d4bd997b82e181fd3b2c07f7246117418fa62af8ecd80f"));
		
	    vSeeds.push_back(CDNSSeedData("node1.truedividendcrypto.org", "node1.truedividendcrypto.org"));
	    vSeeds.push_back(CDNSSeedData("node2.truedividendcrypto.org", "node2.truedividendcrypto.org"));
	    vSeeds.push_back(CDNSSeedData("node3.truedividendcrypto.org", "node3.truedividendcrypto.org"));
        vSeeds.push_back(CDNSSeedData("node4.truedividendcrypto.org", "node4.truedividendcrypto.org"));
        vSeeds.push_back(CDNSSeedData("node5.truedividendcrypto.org", "node5.truedividendcrypto.org"));
        vSeeds.push_back(CDNSSeedData("node6.truedividendcrypto.org", "node6.truedividendcrypto.org"));
        vSeeds.push_back(CDNSSeedData("node7.truedividendcrypto.org", "node7.truedividendcrypto.org"));
        vSeeds.push_back(CDNSSeedData("node8.truedividendcrypto.org", "node8.truedividendcrypto.org"));
        vSeeds.push_back(CDNSSeedData("node9.truedividendcrypto.org", "node9.truedividendcrypto.org"));
        vSeeds.push_back(CDNSSeedData("node10.truedividendcrypto.org", "node10.truedividendcrypto.org"));
		
        base58Prefixes[PUBKEY_ADDRESS] = std::vector<unsigned char>(1, 127);
        base58Prefixes[SCRIPT_ADDRESS] = std::vector<unsigned char>(1, 20);
        base58Prefixes[SECRET_KEY] = std::vector<unsigned char>(1, 8);
        base58Prefixes[EXT_PUBLIC_KEY] = boost::assign::list_of(0x04)(0x88)(0xB2)(0x1E).convert_to_container<std::vector<unsigned char> >();
        base58Prefixes[EXT_SECRET_KEY] = boost::assign::list_of(0x04)(0x88)(0xAD)(0xE4).convert_to_container<std::vector<unsigned char> >();
        base58Prefixes[EXT_COIN_TYPE] = boost::assign::list_of(0x80)(0x00)(0x00)(0x6d).convert_to_container<std::vector<unsigned char> >();

        convertSeed6(vFixedSeeds, pnSeed6_main, ARRAYLEN(pnSeed6_main));

        fRequireRPCPassword = true;
        fMiningRequiresPeers = true;
        fAllowMinDifficultyBlocks = false;
        fDefaultConsistencyChecks = false;
        fRequireStandard = true;
        fMineBlocksOnDemand = false;
        fSkipProofOfWorkCheck = false;
        fTestnetToBeDeprecatedFieldRPC = false;
        fHeadersFirstSyncingActive = false;

        nPoolMaxTransactions = 3;
        strSporkKey = "0478c3e932fbe183b2f665de937866cb1cfc5ed4b0bf733b72286f265ffc03ff52dfd669fbb3f77d630e5393da65c721a9a891d2c4c6aa515dfd25ffe545582357";
	    nStartMasternodePayments = 1547107989; 

	    CBitcoinAddress address;
	    std::string strAddress = "2Qb1kNGfyJLi37bagDQswn2EkGjSCBzokD";
	    SelectParams(CBaseChainParams::MAIN);
	    assert(address.SetString(strAddress));
	    masternodeTestDummyAddress = GetScriptForDestination(address.Get());
	}

    const Checkpoints::CCheckpointData& Checkpoints() const
    {
        return data;
    }
};
static CMainParams mainParams;

class CTestNetParams : public CMainParams
{
public:
    CTestNetParams()
    {
       
    }
    const Checkpoints::CCheckpointData& Checkpoints() const
    {
        return dataTestnet;
    }
};
static CTestNetParams testNetParams;

class CRegTestParams : public CTestNetParams
{
public:
    CRegTestParams()
    {
       
    }
    const Checkpoints::CCheckpointData& Checkpoints() const
    {
        return dataRegtest;
    }
};
static CRegTestParams regTestParams;

class CUnitTestParams : public CMainParams, public CModifiableParams
{
public:
    CUnitTestParams()
    {
        networkID = CBaseChainParams::UNITTEST;
        strNetworkID = "unittest";
        nDefaultPort = 51478;
        vFixedSeeds.clear(); 
        vSeeds.clear();      

        fRequireRPCPassword = false;
        fMiningRequiresPeers = false;
        fDefaultConsistencyChecks = true;
        fAllowMinDifficultyBlocks = false;
        fMineBlocksOnDemand = true;
    }

    const Checkpoints::CCheckpointData& Checkpoints() const
    {
                return data;
    }

    
    virtual void setSubsidyHalvingInterval(int anSubsidyHalvingInterval) { nSubsidyHalvingInterval = anSubsidyHalvingInterval; }
    virtual void setEnforceBlockUpgradeMajority(int anEnforceBlockUpgradeMajority) { nEnforceBlockUpgradeMajority = anEnforceBlockUpgradeMajority; }
    virtual void setRejectBlockOutdatedMajority(int anRejectBlockOutdatedMajority) { nRejectBlockOutdatedMajority = anRejectBlockOutdatedMajority; }
    virtual void setToCheckBlockUpgradeMajority(int anToCheckBlockUpgradeMajority) { nToCheckBlockUpgradeMajority = anToCheckBlockUpgradeMajority; }
    virtual void setDefaultConsistencyChecks(bool afDefaultConsistencyChecks) { fDefaultConsistencyChecks = afDefaultConsistencyChecks; }
    virtual void setAllowMinDifficultyBlocks(bool afAllowMinDifficultyBlocks) { fAllowMinDifficultyBlocks = afAllowMinDifficultyBlocks; }
    virtual void setSkipProofOfWorkCheck(bool afSkipProofOfWorkCheck) { fSkipProofOfWorkCheck = afSkipProofOfWorkCheck; }
};
static CUnitTestParams unitTestParams;


static CChainParams* pCurrentParams = 0;

CModifiableParams* ModifiableParams()
{
    assert(pCurrentParams);
    assert(pCurrentParams == &unitTestParams);
    return (CModifiableParams*)&unitTestParams;
}

const CChainParams& Params()
{
    assert(pCurrentParams);
    return *pCurrentParams;
}

CChainParams& Params(CBaseChainParams::Network network)
{
    switch (network) {
    case CBaseChainParams::MAIN:
        return mainParams;
    case CBaseChainParams::TESTNET:
        return testNetParams;
    case CBaseChainParams::REGTEST:
        return regTestParams;
    case CBaseChainParams::UNITTEST:
        return unitTestParams;
    default:
        assert(false && "Unimplemented network");
        return mainParams;
    }
}

void SelectParams(CBaseChainParams::Network network)
{
    SelectBaseParams(network);
    pCurrentParams = &Params(network);
}

bool SelectParamsFromCommandLine()
{
    CBaseChainParams::Network network = NetworkIdFromCommandLine();
    if (network == CBaseChainParams::MAX_NETWORK_TYPES)
        return false;

    SelectParams(network);
    return true;
}
