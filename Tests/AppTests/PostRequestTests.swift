//
//  PostRequestTests.swift
//  nerdserver
//
//  Created by Falco, Danny on 5/17/18.
//
//

import HTTP
import Vapor
import XCTest
import Testing

@testable import App

class PostRequestTests: XCTestCase {
    
    let droplet = try! Droplet.testable()
    
    override func setUp() {
        super.setUp()
        Testing.onFail = XCTFail
    }
    
    func testCreate() throws {
        
        let testContent = "test content"
        let requestBody = try Body(JSON(node: ["content": testContent]))
        
        let request = Request(method: .post,
                            uri: "/posts",
                            headers: ["Content-Type": "application/json"],
                            body: requestBody)
        
        try droplet.testResponse(to: request)
            .assertStatus(is: .ok)
            .assertJSON("id", passes: {json in json.int != nil })
            .assertJSON("content", equals: testContent)
    }
    
    func testRead() throws {
        
        let request = Request(method: .get, uri: "/posts/1")
        let res = try droplet.respond(to: request)
        print(res)
        res.assertStatus(is: .ok)
        try res.assertJSON("content", equals: "Hello, world!")
        
    }
    
    func testUpdate() throws {
        let post = Post.init(content: "test update1")
        try post.save()
        
        try print("after save \(post.makeJSON() )")
        
        guard let postId = post.id?.int else {
            XCTFail("Error converting post id to int")
            return
        }
        
        post.content = "test update2"
        let json = try post.makeJSON()
        let reqBody = try Body(json)
        
        let updatedPostReq = Request(method: .put, uri: "/posts/\(postId)", headers: ["Content-Type": "application/json"], body: reqBody)
        
        let updatedPostRes = try droplet.testResponse(to: updatedPostReq)
        
        print("updated post res")
        print(updatedPostRes.json!)
        updatedPostRes.assertStatus(is: .ok)
        try updatedPostRes.assertJSON("content", equals: post.content)
        
        /// MARK: CLEANUP
        print("deleting post  \(String(describing: postId))    \(post.content)")
        try post.delete()
    }
    
    func testDelete() throws {
        let post = Post.init(content: "test delete")
        try post.save()
        
        guard let postId = post.id?.int else {
            XCTFail("Error converting post id to int")
            return
        }
        
        let req = Request(method: .delete, uri: "/posts/\(postId)", headers: ["Content-Type": "application/json"], body: Body())
        
        let res = try droplet.testResponse(to: req)
        res.assertStatus(is: .ok)
        res.assertStatus(is: Status.init(statusCode: 200))
        print("code \(res.status.statusCode)")
    }
}
