//
//  DominantColorUnitTests.swift
//  DominantColor
//
//  Created by Lydon Chandra on 27/09/2015.
//  Copyright © 2015 Indragie Karunaratne. All rights reserved.
//

import XCTest
@testable import DominantColor


private func randomNumberInRange(range: Range<Int>) -> Int {
    let interval = range.endIndex - range.startIndex - 1
    let buckets = Int(RAND_MAX) / interval
    let limit = buckets * interval
    var r = 0
    repeat {
        r = Int(rand())
    } while r >= limit
    return range.startIndex + (r / buckets)
}


private extension Array {
    private func randomValues(seed: UInt32, num: Int) -> [Element] {
        srand(seed)
        
        var indices = [Int]()
        indices.reserveCapacity(num)
        let range = 0..<self.count
        for _ in 0..<num {
            var random = 0
            repeat {
                random = randomNumberInRange(range)
            } while indices.contains(random)
            indices.append(random)
        }
        
        return indices.map { self[$0] }
    }
    
    
    
}


class DominantColorUnitTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRBGVectorToCGColor() {
        var aINVector3 = INVector3(x:0, y:0, z:0);
        var inCGColor = DominantColor.RGBVectorToCGColor(aINVector3);
        
        var assertCGColor = CGColorCreate(
            CGColorSpaceCreateDeviceRGB(),
            [CGFloat(0), CGFloat(0), CGFloat(0), 1.0])
        XCTAssertTrue(CGColorEqualToColor(inCGColor, assertCGColor))
        
        aINVector3 = INVector3(x:0, y:0.5000000, z: 0.6000000);
        inCGColor = DominantColor.RGBVectorToCGColor(aINVector3)
        print(inCGColor)
        assertCGColor = CGColorCreate(
                CGColorSpaceCreateDeviceRGB(),
                [CGFloat(0), CGFloat(0.5000000), CGFloat(0.6000000), 1.0])
        print(assertCGColor)
//        XCTAssertTrue(CGColorEqualToColor(inCGColor, assertCGColor))
        XCTAssertTrue(
            CGColorEqualToColorWithTolerance(inCGColor, color2:assertCGColor!, tolerance:0.01) )
        
        aINVector3 = INVector3(x:-0.5, y: -0.5, z: -0.5)
        inCGColor = DominantColor.RGBVectorToCGColor(aINVector3)
        print(inCGColor)
        assertCGColor = CGColorCreate(
            CGColorSpaceCreateDeviceRGB(),
            [CGFloat(0), CGFloat(0), CGFloat(0), 1.0])
        XCTAssertTrue(
            CGColorEqualToColorWithTolerance(inCGColor, color2: assertCGColor!, tolerance: 0.0001))
        
    }
    

    func CGColorEqualToColorWithTolerance(
        color1: CGColor, color2: CGColor, tolerance: CGFloat) -> Bool {
        
            var r1, g1, b1, a1, r2, g2, b2, a2: CGFloat
            let components = CGColorGetComponents(color1)
            r1 = components[0]
            g1 = components[1]
            b1 = components[2]
            a1 = components[3]
            
            let components2 = CGColorGetComponents(color2)
            r2 = components2[0]
            g2 = components2[1]
            b2 = components2[2]
            a2 = components2[3]
            
            if fabs(r2-r1) <= tolerance
                && fabs(g2-g1) <= tolerance
                && fabs(b2-b1) <= tolerance
                && fabs(a2 - a1 ) <= tolerance
            {
                return true
            }
            else {
                return false
            }
    }
    
    

    
    func testDominantColorsInImage() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let testImageFileURL = bundle.URLForResource("all255s32x32", withExtension: "bmp")
        let testImageUIImage = UIImage(contentsOfFile: testImageFileURL!.path!)
        let dominantColorArray = DominantColor.dominantColorsInImage((testImageUIImage?.CGImage)!)
        
        print(dominantColorArray)
        
        for idx in 0..<dominantColorArray.count {
            let currentColor = dominantColorArray[idx]
            let colorComponents = CGColorGetComponents(currentColor)
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let alpha = CGColorGetAlpha(currentColor)
            XCTAssertTrue(red > 0.95 || red < 0.1)
            XCTAssertTrue(blue > 0.95 || blue < 0.1)
            XCTAssertTrue(green > 0.95 || green < 0.1)
            XCTAssertTrue(alpha > 0.95 || alpha < 0.95)
        }	
    }
    
    func testDominantColorsInImage_yellow() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let testImageFileURL = bundle.URLForResource("yellowImage_transparent", withExtension: "png")
        let testImageUIImage = UIImage(contentsOfFile: testImageFileURL!.path!)
        let dominantColorArray = DominantColor.dominantColorsInImage((testImageUIImage?.CGImage)!)
        
        for idx in 0..<dominantColorArray.count {
            let currentColor = dominantColorArray[idx]
            let colorComponents = CGColorGetComponents(currentColor)
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let alpha = CGColorGetAlpha(currentColor)
            //yellow = red + green
            XCTAssertTrue(red < 0.503 && red > 0.501)
            XCTAssertTrue(green < 0.503 && red > 0.501)
            XCTAssertTrue(blue < 0.001)
        }
    }
    
    func testDominantColorsInImage_yellow_black() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let testImageFileURL = bundle.URLForResource("yellowBlackImage", withExtension: "png")
        let testImageUIImage = UIImage(contentsOfFile: testImageFileURL!.path!)
        
        let dominantColorArray = DominantColor.dominantColorsInImage((testImageUIImage?.CGImage)!)
        
        for idx in 0..<dominantColorArray.count {
            let currentColor = dominantColorArray[idx]
            let colorComponents = CGColorGetComponents(currentColor)
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let alpha = CGColorGetAlpha(currentColor)
            
            XCTAssertTrue(true)
            if red > 0.999 {
                //dominantColor1: yellow,
                // red:1, green:1, blue:0
                XCTAssertTrue(green > 0.999)
                XCTAssertTrue(blue < 0.001)
            }
            else if red < 0.001 {
                //dominantColor2: black
                // red:0, green:0, blue:0
                XCTAssertTrue(green < 0.001)
                XCTAssertTrue(blue < 0.001)
            }
            
            print("\(red),\(green),\(blue) " )
            		
        }
    }
    
    
    
    
    func testFindNearestCluster() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let fileURL = testBundle.URLForResource("all255s32x32", withExtension: "bmp")
        
        let ones010 = UIImage(contentsOfFile: fileURL!.path!)
        let inputCGImage = ones010?.CGImage;
        
        var bitmapBytesCount = 0
        var bitmapBytesPerRow = 0
        let pixelsWide = CGImageGetWidth(inputCGImage)
        let pixelsHigh = CGImageGetHeight(inputCGImage)
        
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapBytesCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(Int(bitmapBytesCount))
        
        let context = CGBitmapContextCreate(
            bitmapData,
            pixelsWide,
            pixelsHigh,
            Int(8),
            Int(bitmapBytesPerRow),
            colorSpace,
            CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let rect = CGRect(x: 0, y: 0, width: Int(pixelsWide), height: Int(pixelsHigh))
        
        CGContextClearRect(context, rect)
        CGContextDrawImage(context, rect, inputCGImage)
        
        let dataVoidPointer:UnsafeMutablePointer<Void> = CGBitmapContextGetData(context)
        let dataIntPointer = UnsafePointer<UInt8>(dataVoidPointer)
        
        for heightIdx in 0 ..< pixelsHigh {
            
            for widthIdx in 0 ..< pixelsWide {
                
                let currentIdx = pixelsWide*heightIdx*4		 + widthIdx*4
                let alpha = dataIntPointer[currentIdx]
                let red = dataIntPointer[currentIdx+1]
                let green = dataIntPointer[currentIdx+2]
                let blue = dataIntPointer[currentIdx+3]

//                let color = UIColor(
//                    red: CGFloat(red)/CGFloat(255.0)
//                    , green: CGFloat(green)/CGFloat(255.0)
//                    , blue: CGFloat(blue)/CGFloat(255.0)
//                    , alpha: CGFloat(alpha)/CGFloat(255.0))
                
                print("\(red),\(green),\(blue) ", terminator: ""  )
            }
            print("\n")
        }
        
        var points = [Float](count: 10, repeatedValue: 0)
        let k = 16
        let seed : UInt32 = 3571
        DominantColor.testFunc()
        var centroids = points.randomValues(seed, num: k)
        //let clusterIndex = DominantColor.findNearestCluster(points[0], points, k, CIE76SquaredColorDifference)
        //XCTAssertTrue(clusterIndex > 0)
        XCTAssertTrue(true)
        
//        private func distanceForAccuracy(accuracy: GroupingAccuracy) -> (INVector3, INVector3) -> Float {
//            switch accuracy {
//            case .Low:
//                return CIE76SquaredColorDifference
//            case .Medium:
//                return CIE94SquaredColorDifference()
//            case .High:
//                return CIE2000SquaredColorDifference()
//            }
//        }
        
    }
    
    
    
    
    
    
    
    
    
    func testScratchPad() {
        
//        - (BOOL)color:(UIColor *)color1
//        isEqualToColor:(UIColor *)color2
//        withTolerance:(CGFloat)tolerance {
//            
//            CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
//            [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
//            [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
//            return
//                fabs(r1 - r2) <= tolerance &&
//                    fabs(g1 - g2) <= tolerance &&
//                    fabs(b1 - b2) <= tolerance &&
//                    fabs(a1 - a2) <= tolerance;
//        }
//        
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        var alpha : CGFloat = 0.0
    
        var blueColor = UIColor.brownColor()
        blueColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        NSLog("")
        
//        CGFloat red, green, blue, alpha;
//        
//        //Create a sample color
//        
//        UIColor *redColor = [UIColor redColor];
//        
//        //Call
//        
//        [redColor getRed: &red
//        green: &green
//        blue: &blue
//        alpha: &alpha];
//        NSLog(@"red = %f. Green = %f. Blue = %f. Alpha = %f",
//        red,
//        green,
//        blue,
//        alpha);
    }
    

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }

    
    
    
    
    
    
    
    
    
    
    
    
    
}
