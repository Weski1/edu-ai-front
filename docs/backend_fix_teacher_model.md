# Poprawka błędu AttributeError w user_profile_service.py

## Model Teacher w backendzie
```python
class Teacher(Base):
    __tablename__ = "teachers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)  # <-- TO POLE UŻYWAMY
    subject = Column(String, nullable=False)
    style_prompt = Column(Text, nullable=False)
    avatar_url = Column(String, nullable=True)
    welcome_message = Column(Text, nullable=True)
```

## Problem
```
AttributeError: type object 'Teacher' has no attribute 'first_name'
```

Backend próbuje użyć `Teacher.first_name` i `Teacher.last_name`, ale model ma tylko `Teacher.name`.

## Rozwiązanie

### Plik: `app/services/user_profile_service.py`

**ZMIEŃ tę funkcję:**
```python
def get_user_profile_stats(db: Session, user_id: int) -> UserProfileStats:
    # Ulubiony nauczyciel na podstawie liczby konwersacji
    favorite_teacher_query = (
        db.query(Teacher.first_name, Teacher.last_name, func.count(Conversation.id).label('conversation_count'))
        .join(Conversation, Teacher.id == Conversation.teacher_id)
        .filter(Conversation.user_id == user_id)
        .group_by(Teacher.id, Teacher.first_name, Teacher.last_name)
        .order_by(desc('conversation_count'))
        .first()
    )
    
    favorite_teacher = None
    favorite_teacher_conversations = 0
    if favorite_teacher_query:
        favorite_teacher = f"{favorite_teacher_query[0]} {favorite_teacher_query[1]}"
        favorite_teacher_conversations = favorite_teacher_query[2]
```

**NA:**
```python
def get_user_profile_stats(db: Session, user_id: int) -> UserProfileStats:
    # Ulubiony nauczyciel na podstawie liczby konwersacji
    favorite_teacher_query = (
        db.query(Teacher.name, func.count(Conversation.id).label('conversation_count'))
        .join(Conversation, Teacher.id == Conversation.teacher_id)
        .filter(Conversation.user_id == user_id)
        .group_by(Teacher.id, Teacher.name)
        .order_by(desc('conversation_count'))
        .first()
    )
    
    favorite_teacher = None
    favorite_teacher_conversations = 0
    if favorite_teacher_query:
        favorite_teacher = favorite_teacher_query[0]  # name z modelu
        favorite_teacher_conversations = favorite_teacher_query[1]  # count
```

## Szczegóły zmian

1. ✅ **Zastąp:** `Teacher.first_name, Teacher.last_name` → `Teacher.name`
2. ✅ **Zaktualizuj group_by:** `Teacher.id, Teacher.name` (usuń nieistniejące pola)
3. ✅ **Uproszczenie:** używaj bezpośrednio `name` zamiast konkatenacji
4. ✅ **Poprawne indeksy:** `[0]` = name, `[1]` = count

## Model jest kompatybilny z frontendem
Frontend już oczekuje struktuty:
```json
{
  "id": 1,
  "name": "Dr. Anna Kowalska", 
  "subject": "Matematyka",
  "avatar_url": "..."
}
```

## Status
- ❌ Backend: wymaga tej jednej prostej zmiany
- ✅ Frontend: w pełni kompatybilny i gotowy  
- ✅ Model: struktura jest prawidłowa
