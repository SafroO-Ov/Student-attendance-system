package main

import (
	"encoding/json"
	"fmt"
	"image"
	"image/jpeg"
	"log"
	"net/http"

	"gocv.io/x/gocv"
)

// Response структура для возврата результата
type Response struct {
	Count int `json:"count"`
}

func main() {
	// Загрузка модели из файла
	modelPath := "face.xml" // Укажите путь к загруженному XML-файлу
	classifier := gocv.NewCascadeClassifier()
	if !classifier.Load(modelPath) {
		log.Fatalf("Ошибка загрузки модели: %s", modelPath)
	}
	defer classifier.Close()

	http.HandleFunc("/process", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Только POST запросы разрешены", http.StatusMethodNotAllowed)
			return
		}

		// Получение изображения из POST-запроса
		file, _, err := r.FormFile("image")
		if err != nil {
			http.Error(w, "Ошибка чтения изображения: "+err.Error(), http.StatusBadRequest)
			return
		}
		defer file.Close()

		// Чтение изображения
		img, err := jpeg.Decode(file)
		if err != nil {
			http.Error(w, "Ошибка декодирования изображения: "+err.Error(), http.StatusInternalServerError)
			return
		}

		// Конвертация изображения в формат Mat для обработки в OpenCV
		matImg, err := gocv.ImageToMatRGBA(img)
		if err != nil {
			http.Error(w, "Ошибка преобразования изображения: "+err.Error(), http.StatusInternalServerError)
			return
		}
		defer matImg.Close()

		// Поиск лиц на изображении
		min_img := image.Point{0, 0}
		max_img := image.Point{1000, 1000}
		rects := classifier.DetectMultiScaleWithParams(matImg, 1.8, 2, 2, min_img, max_img)
		count := len(rects)

		// Логирование количества лиц
		fmt.Printf("Обнаружено %d лиц\n", count)

		// Формирование ответа
		response := Response{Count: count}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	})

	fmt.Println("Сервер запущен на порту 5000")
	log.Fatal(http.ListenAndServe(":5000", nil))
}