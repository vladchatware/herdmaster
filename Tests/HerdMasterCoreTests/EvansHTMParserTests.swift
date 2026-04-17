import XCTest
@testable import HerdMasterCore

final class EvansHTMParserTests: XCTestCase {

    private var sampleURL: URL {
        Bundle.module.url(forResource: "evans-sample", withExtension: "htm")!
    }

    func testParsesRabbitryAndBreed() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        XCTAssertEqual(doc.rabbitryName, "3C Rabbitry")
        XCTAssertEqual(doc.breed, "Mini Rex")
    }

    func testRejectsNonEvansFile() {
        let parser = EvansHTMParser()
        let notEvans = "<html><body>Hello world</body></html>"

        XCTAssertThrowsError(try parser.parse(html: notEvans)) { error in
            XCTAssertEqual(error as? EvansImportError, .notAnEvansFile)
        }
    }

    func testParsesSubjectAnimal() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        let subject = doc.animals.first { $0.earNumber == "RUBY" }
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject?.name, "3C RUBY")
        XCTAssertEqual(subject?.sex, .doe)
        XCTAssertEqual(subject?.color, "Otter - Black")
    }

    func testParsesDateWithNbspSeparators() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        let phk1 = doc.animals.first { $0.earNumber == "PHK1" }
        XCTAssertNotNil(phk1?.dateOfBirth)

        let components = Calendar(identifier: .gregorian).dateComponents(
            [.year, .month, .day],
            from: phk1!.dateOfBirth!
        )
        XCTAssertEqual(components.year, 2018)
        XCTAssertEqual(components.month, 10)
        XCTAssertEqual(components.day, 22)
    }

    func testParsesWeightFormat() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        let phk1 = doc.animals.first { $0.earNumber == "PHK1" }
        XCTAssertEqual(phk1?.weightOunces, 56, "3 # 8 oz = 56 oz")

        let rolo = doc.animals.first { $0.earNumber == "ROLO" }
        XCTAssertEqual(rolo?.weightOunces, 67, "4 # 3 oz = 67 oz")
    }

    func testDetectsSexViaClass() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        let males = doc.animals.filter { $0.sex == .buck }.compactMap { $0.earNumber }
        let females = doc.animals.filter { $0.sex == .doe }.compactMap { $0.earNumber }

        XCTAssertTrue(males.contains("PHK1"))
        XCTAssertTrue(males.contains("ROLO"))
        XCTAssertTrue(females.contains("RUBY"))
        XCTAssertTrue(females.contains("BLUEBERRY"))
    }

    func testGrandChampionAndLegs() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        let phk1 = doc.animals.first { $0.earNumber == "PHK1" }
        XCTAssertEqual(phk1?.grandChampion, "T1776")
        XCTAssertEqual(phk1?.legs, 6)
    }

    func testOwnerExtraction() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        XCTAssertNotNil(doc.ownerName)
        XCTAssertTrue(doc.ownerName?.contains("Crawford") ?? false)
        XCTAssertEqual(doc.ownerEmail, "teresacrawford1974@gmail.com")
    }

    func testHTMLEntityDecoding() throws {
        let parser = EvansHTMParser()
        let htmlWithEntities = """
        <META NAME="GENERATOR" CONTENT="Rabbit Register by Evans Software">
        <table><TD rowspan="3" class="female">
        TEST NAME<BR>
        Color<BR>
        Ear #:&nbsp;TEST&nbsp;&nbsp;&nbsp;Reg #:&nbsp;<BR>
        DOB:&nbsp;January&nbsp;15,&nbsp;2020<BR>
        </TD></table>
        """

        let doc = try parser.parse(html: htmlWithEntities)
        let animal = doc.animals.first
        XCTAssertNotNil(animal?.dateOfBirth, "Date must parse after nbsp decoding")

        let components = Calendar(identifier: .gregorian).dateComponents(
            [.year, .month, .day],
            from: animal!.dateOfBirth!
        )
        XCTAssertEqual(components.year, 2020)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 15)
    }

    func testAnimalCount() throws {
        let parser = EvansHTMParser()
        let doc = try parser.parse(fileAt: sampleURL)

        XCTAssertEqual(doc.animals.count, 9, "Expected 9 non-placeholder animals in 3C Ruby sample")
    }
}
