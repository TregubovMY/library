// В своём rails проекте реализовать:
// Кнопка с текстом “Время” справа внизу, которая появляется через 5 секунд после загрузки root страницы
// (у каждого она своя), на других не должно. (для кнопки должны быть минимум установлены свойства цвета и паддинги,
// какие - на своё усмотрение)
// по нажатию на кнопку должно открыться окно справа внизу, кнопка скрыться (как на скринах.
// Тут можно посмотреть пример https://winvestor.ru/ . Списывать оттуда поведение не нужно, у нас всё проще)
//
//     Внутри этого окна отображаем текущее время в формате 15:30:22 (часы:минуты:секунды).
//    Также отображаем крестик, который закрывает окно. После закрытия окна должна появится кнопка.
//
//     Ограничение:
//
// кнопка и открывающееся по клику на неё окно должны быть созданы с помощью js
//
// все стили для них также должны быть написаны на js

document.addEventListener('DOMContentLoaded', () => {
    const timeBtn = createButton("Время", ["btn", "btn-outline-info"], {
        display: "none"
    });

    const timeModal = createModal({
        cursor: "pointer",
        backgroundColor: "white",
        position: "absolute",
        bottom: "0",
        right: "0",
        width: "120px",
        height: "80px",
        display: "none",
        margin: "20px",
        padding: "20px",
        boxShadow: "0px 0px 10px rgba(0, 0, 0, 0.5)"
    });

    const timeDisplay = createTimeDisplay({
        fontSize: "20px",
        color: "black"
    });

    timeModal.appendChild(timeDisplay);

    document.querySelector('html').onclick = (e) => {
        if (!timeModal.contains(e.target) && e.target !== timeBtn) {
            toggleDisplay(timeModal, timeBtn);
        }
    };

    setInterval(updateTime, 1000, timeDisplay);
    updateTime(timeDisplay); // Обновляем время сразу при загрузке

    timeBtn.onclick = () => {
        toggleDisplay(timeBtn, timeModal);
    };

    const divBtn = document.getElementById("btn-time");
    divBtn.style.position = "absolute";
    divBtn.style.bottom = "50px";
    divBtn.style.right = "50px";
    divBtn.appendChild(timeBtn);
    divBtn.appendChild(timeModal);

    setTimeout(() => {
        timeBtn.style.display = 'block';
    }, 5000);
});

function createButton(text, classes, styles) {
    const button = document.createElement('button');
    button.innerText = text;
    button.classList.add(...classes);
    button.setAttribute("type", "button");
    Object.assign(button.style, styles);
    return button;
}

function createModal(styles) {
    const modal = document.createElement('div');
    Object.assign(modal.style, styles);
    return modal;
}

function createTimeDisplay(styles) {
    const display = document.createElement('p');
    Object.assign(display.style, styles);
    return display;
}

function updateTime(display) {
    const now = new Date();
    const second = String(now.getSeconds()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    display.innerText = `${hours}:${minutes}:${second}`;
}

function toggleDisplay(hideElement, showElement) {
    hideElement.style.display = "none";
    showElement.style.display = "block";
}