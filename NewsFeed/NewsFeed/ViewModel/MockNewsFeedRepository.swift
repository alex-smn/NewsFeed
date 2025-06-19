//
//  MockNewsFeedRepository.swift
//  NewsFeed
//
//  Created by Alexander Livshits on 17/06/2025.
//

import Foundation

class MockNewsFeedRepository: NewsFeedRepositoryProtocol {
    func getData(page: Int) async throws -> NewsFeedSourceModel {
        if page < 0 {
            throw NetworkError.incorrectPageNumber
        }
        
        return NewsFeedSourceModel(
            news: [
                NewsItemSourceModel(
                    id: 8572,
                    title: "Представлен Audi Q5 e-hybrid",
                    description: "Audi представила обновленный Q5 прошлой осенью",
                    publishedDate: "2025-06-16T00:00:00",
                    url: "avto-novosti/audi_q5",
                    fullUrl: URL(string: "https://www.autodoc.ru/avto-novosti/audi_q5")!,
                    titleImageUrl: URL(string: "https://file.autodoc.ru/news/avto-novosti/539556915_1.jpg")!,
                    categoryType: "Автомобильные новости"
                ),
                NewsItemSourceModel(
                    id: 8570,
                    title: "Новый Audi Q3: первый взгляд",
                    description: "Обновление модельной линейки Audi идёт своим ходом",
                    publishedDate: "2025-06-11T00:00:00",
                    url: "avto-novosti/audi_q3",
                    fullUrl: URL(string: "https://www.autodoc.ru/avto-novosti/audi_q3")!,
                    titleImageUrl: URL(string: "https://file.autodoc.ru/news/avto-novosti/108082221_1.jpg")!,
                    categoryType: "Автомобильные новости"
                )
            ],
            totalCount: 2
        )
    }
}
