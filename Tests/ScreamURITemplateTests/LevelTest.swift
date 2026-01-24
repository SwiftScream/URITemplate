import ScreamURITemplate
import Testing

struct LevelTest {
    @Test("Template Level 1", arguments: [
        "{var}",
        "'{var}'",
        "{hello}%20{world}",
    ])
    func templateLevel1(templateString: String) async throws {
        let template = try URITemplate(string: templateString)
        #expect(template.level == .level1, "Template level should be Level 1")
    }

    @Test("Template Level 2", arguments: [
        "{+var}",
        "{a}{+hello}",
        "{+path}/here",
        "here?ref={+path}",
        "{#var}",
        "{a}{#b}",
    ])
    func templateLevel2(templateString: String) async throws {
        let template = try URITemplate(string: templateString)
        #expect(template.level == .level2, "Template level should be Level 2")
    }

    @Test("Template Level 3", arguments: [
        "map?{x,y}",
        "{x,hello,y}",
        "{+x,hello,y}",
        "{+path,x}/here",
        "{#x,hello,y}",
        "{#path,x}/here",
        "X{.var}",
        "{a}X{.var}",
        "X{.x,y}",
        "{/var}",
        "{a}{/var}",
        "{/var,x}/here",
        "{;x}",
        "{a}{;x}",
        "{;x,y,empty}",
        "{?x}",
        "{#a}{?x}",
        "{?x,y,empty}",
        "?fixed=yes{&x}",
        "{+a}{&x}",
        "{&x,y,empty}",
    ])
    func templateLevel3(templateString: String) async throws {
        let template = try URITemplate(string: templateString)
        #expect(template.level == .level3, "Template level should be Level 3")
    }

    @Test("Template Level 4", arguments: [
        "{var:3}",
        "{a}{var:3}",
        "{+a}{var:3}",
        "{a,b}{var:3}",
        "{list*}",
        "{?a}{list*}",
        "{a,b}{list*}",
        "{.list*}",
    ])
    func templateLevel4(templateString: String) async throws {
        let template = try URITemplate(string: templateString)
        #expect(template.level == .level4, "Template level should be Level 4")
    }
}
