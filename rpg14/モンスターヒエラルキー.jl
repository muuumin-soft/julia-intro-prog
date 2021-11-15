struct Tボスモンスター end
struct Tザコモンスター end

function モンスターヒエラルキー(モンスター::Tモンスター) 
    if モンスター.isボス
        return Tボスモンスター()
    else
        return Tザコモンスター()
    end
end