import React, { useState } from "react";

function Check() {
  const [students, setStudents] = useState([]);
  const [name, setName] = useState("")
  const [email, setemail] = useState("")
  const [editIndex, setEditIndex] = useState(null);

  const handleName =(e) =>{
    setName(e.target.value)
  }

  const handleEmail =(e) =>{
    setemail(e.target.value)
  }

  const handleSubmit =(e)=>{
    e.preventDefault()
    // Add or Update Student
 if (editIndex !== null) {
      // Update existing student
      const updatedStudents = [...students];
      updatedStudents[editIndex] = { name, email };
      setStudents(updatedStudents);
      
      setEditIndex(null); // exit edit mode
    } else {
      // Add new student
      setStudents([...students, { name, email }]);
    }
  }
  

   const handleEdit = (index) => {
    const student = students[index];
    setEditIndex(index);
    setName(student.name);
    setemail(student.email);
  };
  const handleDelete = (index) => {
  const updatedStudents = students.filter((_, i) => i !== index);
  setStudents(updatedStudents);
};

  return (
    <div style={{ padding: "20px" }}>
      <h1>🎓 School Portal</h1>

      {/* Form */}
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="name"
          value={name}
          placeholder="Student Name"
          onChange={handleName}
        />
        <input
          type="email"
          name="email"
          value={email}
          placeholder="Student Email"
          onChange={handleEmail}
        />
        <button type="submit">
          {editIndex == null ? 'add' :'update'}
        </button>
      </form>

      {/* Student List */}
      <h2>📋 Student List</h2>
      <ul>
        {students.map((student, index) => (
          <li key={index}>
            {student.name} {student.email}
            <button onClick={() => handleEdit(index)}>Edit</button>
            <button onClick={()=> handleDelete(index)}>delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default Check;
