//
//  BasicTypesTests.swift
//  ObjectMapper
//
//  Created by Tristan Himmelman on 2014-12-04.
//  Copyright (c) 2014 hearst. All rights reserved.
//

import Foundation
import XCTest
import ObjectMapper
import Nimble

class BasicTypesTestsToJSON: XCTestCase {

    let mapper = Mapper<BasicTypes>()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	// MARK: Test mapping to JSON and back (basic types: Bool, Int, Double, Float, String)
	
	func testMappingBoolToJSON(){
		let value: Bool = true
		let object = BasicTypes()
		object.bool = value
		object.boolOptional = value
		object.boolImplicityUnwrapped = value
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.bool).to(equal(value))
		expect(mappedObject?.boolOptional).to(equal(value))
		expect(mappedObject?.boolImplicityUnwrapped).to(equal(value))
	}
	
	func testMappingIntToJSON(){
		let value: Int = 11
		let object = BasicTypes()
		object.int = value
		object.intOptional = value
		object.intImplicityUnwrapped = value
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.int).to(equal(value))
		expect(mappedObject?.intOptional).to(equal(value))
		expect(mappedObject?.intImplicityUnwrapped).to(equal(value))
	}

	func testMappingDoubleToJSON(){
		let value: Double = 11
		let object = BasicTypes()
		object.double = value
		object.doubleOptional = value
		object.doubleImplicityUnwrapped = value
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.double).to(equal(value))
		expect(mappedObject?.doubleOptional).to(equal(value))
		expect(mappedObject?.doubleImplicityUnwrapped).to(equal(value))
	}

	func testMappingFloatToJSON(){
		let value: Float = 11
		let object = BasicTypes()
		object.float = value
		object.floatOptional = value
		object.floatImplicityUnwrapped = value
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.float).to(equal(value))
		expect(mappedObject?.floatOptional).to(equal(value))
		expect(mappedObject?.floatImplicityUnwrapped).to(equal(value))
	}
	
	func testMappingStringToJSON(){
		let value: String = "STRINGNGNGG"
		let object = BasicTypes()
		object.string = value
		object.stringOptional = value
		object.stringImplicityUnwrapped = value
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.string).to(equal(value))
		expect(mappedObject?.stringOptional).to(equal(value))
		expect(mappedObject?.stringImplicityUnwrapped).to(equal(value))
	}
	
	func testMappingAnyObjectToJSON(){
		let value: String = "STRINGNGNGG"
		let object = BasicTypes()
		object.anyObject = value
		object.anyObjectOptional = value
		object.anyObjectImplicitlyUnwrapped = value
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.anyObject as? String).to(equal(value))
		expect(mappedObject?.anyObjectOptional as? String).to(equal(value))
		expect(mappedObject?.anyObjectImplicitlyUnwrapped as? String).to(equal(value))
	}
	
	// MARK: Test mapping Arrays to JSON and back (with basic types in them Bool, Int, Double, Float, String)
	
	func testMappingEmptyArrayToJSON(){
		let object = BasicTypes()
		object.arrayBool = []
		object.arrayBoolOptional = []
		object.arrayBoolImplicityUnwrapped = []
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayBool).to(equal([]))
		expect(mappedObject?.arrayBoolOptional!).to(equal([]))
		expect(mappedObject?.arrayBoolImplicityUnwrapped).to(equal([]))
	}
	
	func testMappingBoolArrayToJSON(){
		let value: Bool = true
		let object = BasicTypes()
		object.arrayBool = [value]
		object.arrayBoolOptional = [value]
		object.arrayBoolImplicityUnwrapped = [value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayBool.first).to(equal(value))
		expect(mappedObject?.arrayBoolOptional?.first).to(equal(value))
		expect(mappedObject?.arrayBoolImplicityUnwrapped.first).to(equal(value))
	}
	
	func testMappingIntArrayToJSON(){
		let value: Int = 1
		let object = BasicTypes()
		object.arrayInt = [value]
		object.arrayIntOptional = [value]
		object.arrayIntImplicityUnwrapped = [value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayInt.first).to(equal(value))
		expect(mappedObject?.arrayIntOptional?.first).to(equal(value))
		expect(mappedObject?.arrayIntImplicityUnwrapped.first).to(equal(value))
	}
	
	func testMappingDoubleArrayToJSON(){
		let value: Double = 1.0
		let object = BasicTypes()
		object.arrayDouble = [value]
		object.arrayDoubleOptional = [value]
		object.arrayDoubleImplicityUnwrapped = [value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayDouble.first).to(equal(value))
		expect(mappedObject?.arrayDoubleOptional?.first).to(equal(value))
		expect(mappedObject?.arrayDoubleImplicityUnwrapped.first).to(equal(value))
	}
	
	func testMappingFloatArrayToJSON(){
		let value: Float = 1.001
		let object = BasicTypes()
		object.arrayFloat = [value]
		object.arrayFloatOptional = [value]
		object.arrayFloatImplicityUnwrapped = [value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayFloat.first).to(equal(value))
		expect(mappedObject?.arrayFloatOptional?.first).to(equal(value))
		expect(mappedObject?.arrayFloatImplicityUnwrapped.first).to(equal(value))
	}
	
	func testMappingStringArrayToJSON(){
		let value: String = "Stringgggg"
		let object = BasicTypes()
		object.arrayString = [value]
		object.arrayStringOptional = [value]
		object.arrayStringImplicityUnwrapped = [value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayString.first).to(equal(value))
		expect(mappedObject?.arrayStringOptional?.first).to(equal(value))
		expect(mappedObject?.arrayStringImplicityUnwrapped.first).to(equal(value))
	}
	
	func testMappingAnyObjectArrayToJSON(){
		let value: String = "Stringgggg"
		let object = BasicTypes()
		object.arrayAnyObject = [value]
		object.arrayAnyObjectOptional = [value]
		object.arrayAnyObjectImplicitlyUnwrapped = [value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayAnyObject.first as? String).to(equal(value))
		expect(mappedObject?.arrayAnyObjectOptional?.first as? String).to(equal(value))
		expect(mappedObject?.arrayAnyObjectImplicitlyUnwrapped.first as? String).to(equal(value))
	}
	
	// MARK: Test mapping Dictionaries to JSON and back (with basic types in them Bool, Int, Double, Float, String)
	
	func testMappingEmptyDictionaryToJSON(){
		let object = BasicTypes()
		object.dictBool = [:]
		object.dictBoolOptional = [:]
		object.dictBoolImplicityUnwrapped = [:]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)
		
		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictBool).to(equal([:]))
		expect(mappedObject?.dictBoolOptional!).to(equal([:]))
		expect(mappedObject?.dictBoolImplicityUnwrapped).to(equal([:]))
	}
	
	func testMappingBoolDictionaryToJSON(){
		let key = "key"
		let value: Bool = true
		let object = BasicTypes()
		object.dictBool = [key:value]
		object.dictBoolOptional = [key:value]
		object.dictBoolImplicityUnwrapped = [key:value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictBool[key]).to(equal(value))
		expect(mappedObject?.dictBoolOptional?[key]).to(equal(value))
		expect(mappedObject?.dictBoolImplicityUnwrapped[key]).to(equal(value))
	}
	
	func testMappingIntDictionaryToJSON(){
		let key = "key"
		let value: Int = 11
		let object = BasicTypes()
		object.dictInt = [key:value]
		object.dictIntOptional = [key:value]
		object.dictIntImplicityUnwrapped = [key:value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictInt[key]).to(equal(value))
		expect(mappedObject?.dictIntOptional?[key]).to(equal(value))
		expect(mappedObject?.dictIntImplicityUnwrapped[key]).to(equal(value))
	}
	
	func testMappingDoubleDictionaryToJSON(){
		let key = "key"
		let value: Double = 11
		let object = BasicTypes()
		object.dictDouble = [key:value]
		object.dictDoubleOptional = [key:value]
		object.dictDoubleImplicityUnwrapped = [key:value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictDouble[key]).to(equal(value))
		expect(mappedObject?.dictDoubleOptional?[key]).to(equal(value))
		expect(mappedObject?.dictDoubleImplicityUnwrapped[key]).to(equal(value))
	}
	
	func testMappingFloatDictionaryToJSON(){
		let key = "key"
		let value: Float = 11
		let object = BasicTypes()
		object.dictFloat = [key:value]
		object.dictFloatOptional = [key:value]
		object.dictFloatImplicityUnwrapped = [key:value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictFloat[key]).to(equal(value))
		expect(mappedObject?.dictFloatOptional?[key]).to(equal(value))
		expect(mappedObject?.dictFloatImplicityUnwrapped[key]).to(equal(value))
	}
	
	func testMappingStringDictionaryToJSON(){
		let key = "key"
		let value = "value"
		let object = BasicTypes()
		object.dictString = [key:value]
		object.dictStringOptional = [key:value]
		object.dictStringImplicityUnwrapped = [key:value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictString[key]).to(equal(value))
		expect(mappedObject?.dictStringOptional?[key]).to(equal(value))
		expect(mappedObject?.dictStringImplicityUnwrapped[key]).to(equal(value))
	}

	func testMappingAnyObjectDictionaryToJSON(){
		let key = "key"
		let value = "value"
		let object = BasicTypes()
		object.dictAnyObject = [key:value]
		object.dictAnyObjectOptional = [key:value]
		object.dictAnyObjectImplicitlyUnwrapped = [key:value]
		
		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictAnyObject[key] as? String).to(equal(value))
		expect(mappedObject?.dictAnyObjectOptional?[key] as? String).to(equal(value))
		expect(mappedObject?.dictAnyObjectImplicitlyUnwrapped[key] as? String).to(equal(value))
	}

	func testMappingIntEnumToJSON(){
		let value = BasicTypes.EnumInt.Another
		let object = BasicTypes()
		object.enumInt = value
		object.enumIntOptional = value
		object.enumIntImplicitlyUnwrapped = value

		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.enumInt).to(equal(value))
		expect(mappedObject?.enumIntOptional).to(equal(value))
		expect(mappedObject?.enumIntImplicitlyUnwrapped).to(equal(value))
	}

	func testMappingDoubleEnumToJSON(){
		let value = BasicTypes.EnumDouble.Another
		let object = BasicTypes()
		object.enumDouble = value
		object.enumDoubleOptional = value
		object.enumDoubleImplicitlyUnwrapped = value

		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.enumDouble).to(equal(value))
		expect(mappedObject?.enumDoubleOptional).to(equal(value))
		expect(mappedObject?.enumDoubleImplicitlyUnwrapped).to(equal(value))
	}

	func testMappingFloatEnumToJSON(){
		let value = BasicTypes.EnumFloat.Another
		let object = BasicTypes()
		object.enumFloat = value
		object.enumFloatOptional = value
		object.enumFloatImplicitlyUnwrapped = value

		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.enumFloat).to(equal(value))
		expect(mappedObject?.enumFloatOptional).to(equal(value))
		expect(mappedObject?.enumFloatImplicitlyUnwrapped).to(equal(value))
	}

	func testMappingStringEnumToJSON(){
		let value = BasicTypes.EnumString.Another
		let object = BasicTypes()
		object.enumString = value
		object.enumStringOptional = value
		object.enumStringImplicitlyUnwrapped = value

		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.enumString).to(equal(value))
		expect(mappedObject?.enumStringOptional).to(equal(value))
		expect(mappedObject?.enumStringImplicitlyUnwrapped).to(equal(value))
	}

	func testMappingEnumIntArrayToJSON(){
		let value = BasicTypes.EnumInt.Another
		let object = BasicTypes()
		object.arrayEnumInt = [value]
		object.arrayEnumIntOptional = [value]
		object.arrayEnumIntImplicitlyUnwrapped = [value]

		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.arrayEnumInt.first).to(equal(value))
		expect(mappedObject?.arrayEnumIntOptional?.first).to(equal(value))
		expect(mappedObject?.arrayEnumIntImplicitlyUnwrapped?.first).to(equal(value))
	}

	func testMappingEnumIntDictionaryToJSON(){
		let key = "key"
		let value = BasicTypes.EnumInt.Another
		let object = BasicTypes()
		object.dictEnumInt = [key: value]
		object.dictEnumIntOptional = [key: value]
		object.dictEnumIntImplicitlyUnwrapped = [key: value]

		let JSONString = Mapper().toJSONString(object, prettyPrint: true)
		let mappedObject = mapper.map(JSONString!)

		expect(mappedObject).notTo(beNil())
		expect(mappedObject?.dictEnumInt[key]).to(equal(value))
		expect(mappedObject?.dictEnumIntOptional?[key]).to(equal(value))
		expect(mappedObject?.dictEnumIntImplicitlyUnwrapped?[key]).to(equal(value))
	}

	func testObjectToModelDictionnaryOfPrimitives() {
		let object = TestCollectionOfPrimitives()
		object.dictStringString = ["string": "string"]
		object.dictStringBool = ["string": false]
		object.dictStringInt = ["string": 1]
		object.dictStringDouble = ["string": 1.2]
		object.dictStringFloat = ["string": 1.3]
		
		let json = Mapper<TestCollectionOfPrimitives>().toJSON(object)

		expect(json["dictStringString"] as? [String:String]).notTo(beEmpty())
		expect(json["dictStringBool"] as? [String:Bool]).notTo(beEmpty())
		expect(json["dictStringInt"] as? [String:Int]).notTo(beEmpty())
		expect(json["dictStringDouble"] as? [String:Double]).notTo(beEmpty())
		expect(json["dictStringFloat"] as? [String:Float]).notTo(beEmpty())
		expect(json["dictStringString"]?["string"]).to(equal("string"))
	}
}
