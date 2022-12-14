// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../contracts/access/Ownable.sol";

import "../../contracts/utils/Counters.sol";

import "../../contracts/utils/math/SafeMath.sol";

import "../../contracts/token/ERC20/IERC20.sol";


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


library Model {

    struct GameInfo {

        // ID

        uint256 id;

        // A???

        string a_team;

        // B???

        string b_team;

        // A???logo

        string a_team_logo;

        // B???logo

        string b_team_logo;

        // ??????

        string label;

        // ??????????????????

        uint64 bet_start_time;

        // ??????????????????

        uint64 bet_end_time;

        // ??????????????????

        uint64 game_start_time;

        // ????????????????????????

        uint256 total_bet_amount;

        // ?????????????????????

        uint256 win_bet_amount;

        // ?????????????????????

        uint256 fail_bet_amount;

        // ?????????????????????

        uint256 draw_bet_amount;

        // ??????????????????

        uint256 win_odds;

        // ??????????????????

        uint256 fail_odds;

        // ??????????????????

        uint256 draw_odds;

        // ??????????????????

        bool is_end;

        //????????????

        uint8 rst;

        // A?????????

        uint256 a_score;

        // B?????????

        uint256 b_score;

        // ??????????????????

        uint256 system_dividend;

        // ????????????

        BetInfo[] bet_infos;

        // ????????????

        WithDrawLog[] with_draw_logs;

        // ??????????????????

        bool is_hav;

    }



    struct BetInfo {

        // ????????????

        address addr;

        // ????????????

        uint256 amount;

        // ????????????

        uint8 t;

    }



    struct WithDrawLog {

        // ????????????

        address addr;

        // ????????????

        uint256 amount;

    }

}



contract Cup is Ownable {

    // ??????token??????

    IERC20 STAKE_TOKEN;

    // ??????????????????

    address PLATFORM_ADDRESS;

    // ??????????????????

    uint256 public SYSTEM_DIVIDEND_RATIO = 10;

    // ??????????????????

    uint256 public MIN_BET_AMOUNT = 1 ether;

    // ?????? ???0,???1,???2

    uint8 constant WIN = 0;

    uint8 constant FAIL = 1;

    uint8 constant DRAW = 2;



    // ????????????ID

    using Counters for Counters.Counter;

    Counters.Counter private _gameIds;

    mapping(uint256 => Model.GameInfo) private _game;



    constructor(address _token_addr, address _platform_addr) {

        STAKE_TOKEN = IERC20(_token_addr);

        STAKE_TOKEN.approve(address(this), 1000000000 ether);

        PLATFORM_ADDRESS = _platform_addr;

    }



    // ????????????

    function createGame(

        string memory a_team,

        string memory b_team,

        string memory a_team_logo,

        string memory b_team_logo,

        string memory label,

        uint64 bet_start_time,

        uint64 bet_end_time,

        uint64 game_start_time

    ) public returns (uint256) {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        require(

            bet_start_time < bet_end_time && bet_end_time < game_start_time,

            "time invalid"

        );



        _gameIds.increment();

        uint256 gameId = _gameIds.current();

        _game[gameId].id = gameId;

        _game[gameId].a_team = a_team;

        _game[gameId].b_team = b_team;

        _game[gameId].a_team_logo = a_team_logo;

        _game[gameId].b_team_logo = b_team_logo;

        _game[gameId].label = label;

        _game[gameId].bet_start_time = bet_start_time;

        _game[gameId].bet_end_time = bet_end_time;

        _game[gameId].game_start_time = game_start_time;

        return gameId;

    }



    // ????????????

    function updateGame(

        uint256 gameId,

        string memory a_team,

        string memory b_team,

        string memory a_team_logo,

        string memory b_team_logo,

        string memory label,

        uint64 bet_start_time,

        uint64 bet_end_time,

        uint64 game_start_time

    ) external {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        require(_game[gameId].id != 0, "no data");

        require(

            bet_start_time < bet_end_time && bet_end_time < game_start_time,

            "time invalid"

        );

        _game[gameId].a_team = a_team;

        _game[gameId].b_team = b_team;

        _game[gameId].a_team_logo = a_team_logo;

        _game[gameId].b_team_logo = b_team_logo;

        _game[gameId].label = label;

        _game[gameId].bet_start_time = bet_start_time;

        _game[gameId].bet_end_time = bet_end_time;

        _game[gameId].game_start_time = game_start_time;

    }



    // ????????????

    function announce(

        uint256 gameId,

        uint256 a_score,

        uint256 b_score

    ) public {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        require(_game[gameId].id != 0, "no data");

        require(_game[gameId].is_end == false, "this game is end");

        _game[gameId].a_score = a_score;

        _game[gameId].b_score = b_score;

        if (a_score == b_score) {

            _game[gameId].rst = DRAW;

        }

        if (a_score > b_score) {

            _game[gameId].rst = WIN;

        }

        if (a_score < b_score) {

            _game[gameId].rst = FAIL;

        }

        _game[gameId].is_end = true;

    }



    // ????????????????????????

    function setSystemDividendRatio(uint256 value) public returns (bool) {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        require(value > 0 && value < 100, "value should be between 0 and 100");

        SYSTEM_DIVIDEND_RATIO = value;

        return true;

    }



    // ????????????????????????

    function setMinBetAmount(uint256 value) public returns (bool) {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        require(value > 0, "value should be more than 0");

        MIN_BET_AMOUNT = value;

        return true;

    }



    // ??????

    function bet(

        uint256 gameId,

        uint256 amount,

        uint8 t

    ) external {

        require(_game[gameId].id != 0, "no data");

        require(amount >= MIN_BET_AMOUNT, "amount more than min bet amount");

        require(_game[gameId].is_end == false, "this game bet is end");

        STAKE_TOKEN.transferFrom(_msgSender(), address(this), amount);



        if (t == WIN) {

            uint256 _win_old = _game[gameId].win_bet_amount;

            (, _game[gameId].win_bet_amount) = SafeMath.tryAdd(

                _win_old,

                amount

            );

        }

        if (t == FAIL) {

            uint256 _fail_old = _game[gameId].fail_bet_amount;

            (, _game[gameId].fail_bet_amount) = SafeMath.tryAdd(

                _fail_old,

                amount

            );

        }

        if (t == DRAW) {

            uint256 _draw_old = _game[gameId].draw_bet_amount;

            (, _game[gameId].draw_bet_amount) = SafeMath.tryAdd(

                _draw_old,

                amount

            );

        }

        uint256 _total_old = _game[gameId].total_bet_amount;

        (, _game[gameId].total_bet_amount) = SafeMath.tryAdd(

            _total_old,

            amount

        );



        Model.BetInfo memory _bet_info = Model.BetInfo({

        addr: _msgSender(),

        amount: amount,

        t: t

        });

        _game[gameId].bet_infos.push(_bet_info);



        //??????????????????

        uint256 _mul_value;

        (, _mul_value) = SafeMath.tryMul(

            _game[gameId].total_bet_amount,

            SYSTEM_DIVIDEND_RATIO

        );

        (, _game[gameId].system_dividend) = SafeMath.tryDiv(_mul_value, 100);



        // ????????????

        _odds(gameId);

    }



    // ????????????

    function getGame(uint256 gameId)

    public

    view

    virtual

    returns (Model.GameInfo memory)

    {

        require(_game[gameId].id != 0, "no data");

        return _game[gameId];

    }



    // ?????????????????????

    function getDivideAmount(uint256 gameId)

    public

    view

    virtual

    returns (uint256)

    {

        return _getDivideAmount(gameId);

    }



    // ?????????????????????

    function _getDivideAmount(uint256 gameId) internal view returns (uint256) {

        require(_game[gameId].id != 0, "no data");

        uint256 _amount;

        (, _amount) = SafeMath.tryMul(

            _game[gameId].total_bet_amount,

            100 - SYSTEM_DIVIDEND_RATIO

        );

        return _amount;

    }



    // ??????

    function harvest(uint256 gameId, uint8 t)

    public

    view

    virtual

    returns (uint256)

    {

        return _harvest(gameId, _msgSender(), t);

    }



    // ??????

    function _harvest(

        uint256 gameId,

        address _address,

        uint8 t

    ) internal view returns (uint256) {

        require(_game[gameId].id != 0, "no data");

        uint256 _d_value = _shareRatio(gameId, _address, t);

        return

        SafeMath.mul(

            SafeMath.div(_getDivideAmount(gameId), 1000000),

            _d_value

        );

    }



    // ????????????????????????????????????

    function totalAmountByType(uint256 gameId, uint8 t)

    public

    view

    virtual

    returns (uint256)

    {

        return _totalAmountByType(gameId, _msgSender(), t);

    }



    // ????????????????????????????????????

    function _totalAmountByType(

        uint256 gameId,

        address _address,

        uint8 t

    ) internal view returns (uint256) {

        require(_game[gameId].id != 0, "no data");

        uint256 _b_amount;

        for (uint256 i = 0; i < _game[gameId].bet_infos.length; i++) {

            if (

                _game[gameId].bet_infos[i].t == t &&

                _game[gameId].bet_infos[i].addr == _address

            ) {

                uint256 _temp = _game[gameId].bet_infos[i].amount;

                (, _b_amount) = SafeMath.tryAdd(_b_amount, _temp);

            }

        }

        return _b_amount;

    }



    // ????????????????????????

    function shareRatio(uint256 gameId, uint8 t)

    public

    view

    virtual

    returns (uint256)

    {

        return _shareRatio(gameId, _msgSender(), t);

    }



    // ????????????????????????

    function _shareRatio(

        uint256 gameId,

        address _address,

        uint8 t

    ) internal view returns (uint256) {

        require(_game[gameId].id != 0, "no data");

        uint256 _b_amount = _totalAmountByType(gameId, _address, t);

        uint256 _c_amount;

        if (t == WIN) {

            _c_amount = _game[gameId].win_bet_amount;

        }

        if (t == FAIL) {

            _c_amount = _game[gameId].fail_bet_amount;

        }

        if (t == DRAW) {

            _c_amount = _game[gameId].draw_bet_amount;

        }

        return SafeMath.div(SafeMath.mul(_b_amount, 1000000), _c_amount);

    }



    // ????????????

    function _odds(uint256 gameId) internal {

        uint256 _amount = _getDivideAmount(gameId);

        if (_game[gameId].win_bet_amount > 0) {

            _game[gameId].win_odds = SafeMath.div(

                SafeMath.mul(_amount, 100),

                _game[gameId].win_bet_amount

            );

        }



        if (_game[gameId].fail_bet_amount > 0) {

            _game[gameId].fail_odds = SafeMath.div(

                SafeMath.mul(_amount, 100),

                _game[gameId].fail_bet_amount

            );

        }



        if (_game[gameId].draw_bet_amount > 0) {

            _game[gameId].draw_odds = SafeMath.div(

                SafeMath.mul(_amount, 100),

                _game[gameId].draw_bet_amount

            );

        }

    }



    // ????????????

    function platformWithdraw(uint256 gameId) external {

        require(_game[gameId].id != 0, "no data");

        require(_game[gameId].is_end == true, "this game bet is end");

        require(_game[gameId].is_hav == false, "this game is harvest");

        require(

            _msgSender() == PLATFORM_ADDRESS,

            "caller is not the PLATFORM_ADDRESS"

        );

        if (_game[gameId].bet_infos.length < 2) {

            return;

        }

        // ????????????

        uint256 amount = _game[gameId].system_dividend;

        if (amount > 0) {

            STAKE_TOKEN.transferFrom(address(this), _msgSender(), amount);

            _game[gameId].is_hav = true;

        }

    }



    // ??????

    function withdraw(uint256 gameId) external {

        require(_game[gameId].id != 0, "no data");

        for (uint256 i = 0; i < _game[gameId].with_draw_logs.length; i++) {

            if (_game[gameId].with_draw_logs[i].addr == _msgSender()) {

                return;

            }

        }

        // ??????????????????

        if (_game[gameId].bet_infos.length == 1) {

            if (_game[gameId].bet_infos[0].t == _game[gameId].rst) {

                STAKE_TOKEN.transferFrom(

                    address(this),

                    _msgSender(),

                    _game[gameId].bet_infos[0].amount

                );

                Model.WithDrawLog memory log = Model.WithDrawLog({

                addr: _msgSender(),

                amount: _game[gameId].bet_infos[0].amount

                });

                _game[gameId].with_draw_logs.push(log);

                return;

            }

        }

        uint256 amount = _harvest(gameId, _msgSender(), _game[gameId].rst);

        if (amount > 0) {

            STAKE_TOKEN.transferFrom(address(this), _msgSender(), amount);

            Model.WithDrawLog memory log = Model.WithDrawLog({

            addr: _msgSender(),

            amount: amount

            });

            _game[gameId].with_draw_logs.push(log);

        }

    }

}

